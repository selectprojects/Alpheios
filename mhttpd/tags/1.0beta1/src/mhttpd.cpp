//****************************************************************************
//
// Alpheios http daemon
//
//****************************************************************************
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <signal.h>
#include <ctype.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <algorithm>
#include <map>
#include <vector>

using namespace std;

namespace
{

const int   BUFSIZE = 8192;
const int   MAXARGS = 100;

enum    MessageType
{
    MT_ERROR = 1,
    MT_INFO = 2
};

enum    SpecialType
{
    ST_NONE = 0,
    ST_CONTINUE = 1,
    ST_EXIT = 2
};

struct  ProgramInfo
{
    string          d_mimeType;
    string          d_path;
    vector<string>  d_args;
};

typedef map<string, ProgramInfo>    ProgramMap;
typedef map<string, string>         ArgMap;

string      f_confName;
ProgramMap  f_programs;
int         f_port;
bool        f_verbose = false;
int         f_attachCount = 0;
const char* f_GET = "GET ";
const char* f_startPlainText = "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\n";

void  logMessage(MessageType, const char*, const char* = NULL, int = 0, int = 0);

//****************************************************************************
//
//  hex2char() - convert hexadecimal character to integer value
//
//  Parameters:
//      a_hex           hex char to convert
//
//  Return value:
//      If valid hex character [0-9A-Fa-f], equivalent value (0-15)
//      If invalid, -1
//
//****************************************************************************
inline  char hex2char(char a_hex)
{
    if (('0' <= a_hex) && (a_hex <= '9'))
        return (a_hex - '0');
    if (('a' <= a_hex) && (a_hex <= 'f'))
        return (a_hex - 'a') + 10;
    if (('A' <= a_hex) && (a_hex <= 'F'))
        return (a_hex - 'A') + 10;
    return -1;
}

//****************************************************************************
//
//  decodeURI() - convert escaped URI characters back to original chars
//
//  Parameters:
//      a_uriStart  start of string to convert
//      a_uriEnd    end of string to convert
//
//  Return value:
//      converted string
//
//****************************************************************************
string decodeURI(const char* a_uriStart, const char* a_uriEnd)
{
    // if too short to have any escape sequences, return whole string
    if ((a_uriEnd - a_uriStart) < 3)
        return string(a_uriStart, a_uriEnd);

    // for each character that could start an escape sequence
    const char* lastStart = a_uriEnd - 2;
    string      outStr;
    outStr.reserve(a_uriEnd - a_uriStart);
    while (a_uriStart < lastStart)
    {
        // if possible escape sequence
        if (*a_uriStart == '%')
        {
            char hiNibble = hex2char(a_uriStart[1]);
            char loNibble;

            // if valid escape sequence (% plus two hex digits)
            if ((hiNibble != -1) && ((loNibble = hex2char(a_uriStart[2])) != -1))
            {
                // add to string and skip escape sequence
                outStr += char((hiNibble << 4) + loNibble);
                a_uriStart += 3;
                continue;
            }
            // otherwise, fall through and treat as non-escape
        }

        // not an escaped character
        outStr += *a_uriStart++;
    }

    // copy last characters
    while (a_uriStart < a_uriEnd)
        outStr += *a_uriStart++;

    return outStr;
}

//****************************************************************************
//
//  usage() - give usage message
//
//  Parameters:
//      a_argc          number of arguments
//      a_argv          array of pointers to arguments
//
//****************************************************************************
void    usage(int a_argc, char** a_argv)
{
    cout << "Usage: " << a_argv[0] << " <config-file>\n";
    cout << "Config file has:\n";
    cout << "  port=<number> [verbose]\n";
    cout << "  <name1>=<mime-type1> <path1> <args1>\n";
    cout << "  <name2>=<mime-type2> <path2> <args2>\n";
    cout << "  ...\n";
    cout << endl;
    cout << "URL http://<machine>:<number>/<name>?<arg1>=<val1>... means\n";
    cout << "execute program corresponding to <name>, substituting values\n";
    cout << "for named arguments in <args>, returning standard output from\n";
    cout << "the execution as a document with the specified mime type.\n";
    cout << endl;
    cout << "For example, if config file has\n";
    cout << "  port=8200\n";
    cout << "  dog=text/html /pets/doginfo.exe <org> <breed>\n";
    cout << "  toy=text/plain /pets/doginfo.exe <org> toy-<breed>\n";
    cout << "then URL\n";
    cout << "  http://myserver:8200/dog?breed=weimaraner?org=AKC\n";
    cout << "returns as HTML the output of\n";
    cout << "  /pets/doginfo AKC weimaraner\n";
    cout << "while\n";
    cout << "  http://myserver:8200/toy?breed=weimaraner?org=AKC\n";
    cout << "returns as text the output of\n";
    cout << "  /pets/doginfo AKC toy-weimaraner\n";
    cout << endl;
    cout << "Errors are written to mhttpd.log in the same directory as the\n";
    cout << "executable.  If the verbose keyword appears after the port,\n";
    cout << "informational messages are also written to the log.\n";
    cout << flush;
}

//****************************************************************************
//
//  readConfig() - read configuration file
//
//  Parameters:
//      a_confName      name of configuration file
//
//****************************************************************************
void    readConfig(const char* a_confName)
{
    // get port
    f_confName = a_confName;
    ifstream    confFile(f_confName.c_str());
    if (!confFile.is_open())
    {
        cout << " Bad configuration file" << endl;
        logMessage(MT_ERROR, "Bad configuration file", a_confName);
    }
    string      confLine;
    string      temp;
    getline(confFile, confLine);
    string::const_iterator  sBegin = confLine.begin();
    string::const_iterator  sEnd = confLine.end();
    string::const_iterator  delim = find(sBegin, sEnd, '=');
    temp.assign(sBegin, delim);
    if ((temp != "port") || (delim == sEnd))
    {
        cout << "Port not specified in configuration file" << endl;
        logMessage(MT_ERROR, "Port not specified in configuration file", a_confName);
    }
    sBegin = ++delim;
    delim = find(sBegin, sEnd, ' ');
    temp.assign(sBegin, delim);
    f_port = atoi(temp.c_str());

    // get flags
    while (delim != sEnd)
    {
        sBegin = ++delim;
        delim = find(sBegin, sEnd, ' ');
        temp.assign(sBegin, delim);
        if (temp == "verbose")
            f_verbose = true;
    }
    logMessage(MT_INFO, "config", a_confName);

    // for each following line
    while (!confFile.eof())
    {
        getline(confFile, confLine);
        if (confFile.eof())
            break;

        // get label
        sBegin = confLine.begin();
        sEnd = confLine.end();
        delim = find(sBegin, sEnd, '=');
        ProgramMap::value_type  programData(string(sBegin, delim),
                                            ProgramInfo());
        if (sEnd - delim <= 1)  // no delimiter or delimiter is final char
        {
            cout << "No mime type specified in line: " << confLine << endl;
            logMessage(MT_ERROR, "No mime type specified in line", confLine.c_str());
        }

        // get mime type
        sBegin = ++delim;
        delim = find(sBegin, sEnd, '|');
        programData.second.d_mimeType.assign(sBegin, delim);
        if (sEnd - delim <= 1)  // no delimiter or delimiter is final char
        {
            cout << "No program specified in line: " << confLine << endl;
            logMessage(MT_ERROR, "No program specified in line", confLine.c_str());
        }

        // get program
        sBegin = ++delim;
        delim = find(sBegin, sEnd, '|');
        programData.second.d_path.assign(sBegin, delim);

        // get args
        while (delim != sEnd)
        {
            sBegin = ++delim;
            delim = find(sBegin, sEnd, '|');
            programData.second.d_args.push_back(string(sBegin, delim));
        }
        if (programData.second.d_args.size() > MAXARGS)
        {
           logMessage(MT_ERROR,
                      "too many arguments",
                      programData.second.d_path.c_str(),
                      programData.second.d_args.size());
        }

        f_programs.insert(programData);
    }
}

//****************************************************************************
//
//  logMessage() - logging function
//
//  Parameters:
//      a_type      type of message (error or information)
//      a_s1        first string
//      a_s2        second string (default=NULL)
//      a_num       number value (default=0 for none)
//      a_fd        where to write HTML version (default=0 for none)
//
//****************************************************************************
void        logMessage(
MessageType a_type,
const char* a_s1,
const char* a_s2,
int         a_num,
int         a_fd)
{
    // if informational and not enabled, do nothing
    if ((a_type == MT_INFO) && !f_verbose)
        return;

    string  logBuffer;
    char    temp[50];
    int     savErrno = errno;

    if ((a_type == MT_ERROR) && a_fd)
    {
        logBuffer = "<HTML><BODY><H1>Error: ";
        logBuffer += a_s1;
        if (a_s2)
        {
            logBuffer += ':';
            logBuffer += a_s2;
        }
        if (a_num)
        {
            logBuffer += '=';
            sprintf(temp, "%d", a_num);
            logBuffer += temp;
        }
        logBuffer += "</H1></BODY></HTML>\r\n";
        write(a_fd, logBuffer.c_str(), logBuffer.size());
    }

    time_t  tmSecs;
    tm      tmBuf;
    time(&tmSecs);
    gmtime_r(&tmSecs, &tmBuf);
    sprintf(temp, "%04d%02d%02dT%02d%02d%02d ",
            tmBuf.tm_year + 1900,
            tmBuf.tm_mon + 1,
            tmBuf.tm_mday,
            tmBuf.tm_hour,
            tmBuf.tm_min,
            tmBuf.tm_sec);
    logBuffer = temp;
    logBuffer += ((a_type == MT_ERROR) ? "ERROR[" : "INFO[");
    sprintf(temp, "%d", getpid());
    logBuffer += temp;
    logBuffer += "]: ";
    logBuffer += a_s1;
    if (a_s2)
    {
        logBuffer += ':';
        logBuffer += a_s2;
    }
    if (a_num)
    {
        logBuffer += '=';
        sprintf(temp, "%d", a_num);
        logBuffer += temp;
    }

    if ((a_type == MT_ERROR) && savErrno)
    {
        logBuffer += " Errno=";
        sprintf(temp, "%d", savErrno);
        logBuffer += temp;
        logBuffer += " [";
        logBuffer += strerror(savErrno);
        logBuffer += ']';
    }

    logBuffer += '\n';

    // no checks here, nothing can be done for a failure anyway
    int     fd;
    if ((fd = open("mhttpd.log", O_CREAT | O_WRONLY | O_APPEND, 0644)) >= 0)
    {
        write(fd, logBuffer.c_str(), logBuffer.size());
        close(fd);
    }

    // kill child if not informational
    if (a_type == MT_ERROR)
        exit(3);
}

//****************************************************************************
//
//  web() - child web server process
//
//  Parameters:
//      a_fd            where to write output
//      a_request       label from request
//      a_args          arguments from request
//
//****************************************************************************
void web(int a_fd, string a_label, string a_args)
{
    char    buffer[BUFSIZE+1];

    // check for special labels
    // dump config
    bool    special = false;
    if (a_label == "config")
    {
        special = true;
        write(a_fd, f_startPlainText, strlen(f_startPlainText));

        ifstream    confFile(f_confName.c_str());
        string      confLine;
        while (!confFile.eof())
        {
            getline(confFile, confLine);
            if (confFile.eof())
                break;
            write(a_fd, confLine.c_str(), confLine.size());
            write(a_fd, "\r\n", 2);
        }
    }

    // if special, finish up
    if (special)
    {
#ifdef LINUX
        sleep(1);       /* to allow socket to drain */
#endif
        exit(1);
    }

    // see if label is valid
    ProgramInfo programInfo = f_programs[a_label];
    if (programInfo.d_path.size() == 0)
    {
        // return error as content
        string  errMsg(f_startPlainText);
        errMsg += "Invalid label: ";
        errMsg += a_label;
        write(a_fd, errMsg.c_str(), errMsg.size());

        // don't bother logging an icon request
        if (a_label != "favicon.ico")
        {
            // note: logMessage() will exit
            errno = 0;
            logMessage(MT_ERROR, "bad label", a_label.c_str());
        }
        exit(1);
    }

    // build list of values from arguments
    ArgMap  argMap;
    string::const_iterator  argStart = a_args.begin();
    string::const_iterator  argEnd = a_args.end();
    while (argStart != argEnd)
    {
        // skip initial delimiter if there, otherwise done
        if (*argStart != '?')
            break;
        ++argStart;

        // pick apart key and value pairs
        string::const_iterator  pairDelim = find(argStart, argEnd, '?');
        string::const_iterator  keyDelim = find(argStart, pairDelim, '=');
        string::const_iterator  valueBegin = keyDelim;
        if (*keyDelim == '=')
            ++valueBegin;
        argMap.insert(make_pair("<" + string(argStart, keyDelim) + ">",
                                string(valueBegin, pairDelim)));

        // get ready for next pair
        argStart = pairDelim;
    }

    // replace args with values
    vector<string>::iterator    aNext = programInfo.d_args.begin();
    vector<string>::iterator    aEnd = programInfo.d_args.end();
    // for each argument
    for (; aNext != aEnd; ++aNext)
    {
        ArgMap::const_iterator          mNext = argMap.begin();
        ArgMap::const_iterator          mEnd = argMap.end();

        // for each possible mapped value
        for (; mNext != mEnd; ++mNext)
        {
            size_t  argPos = 0;
            while ((argPos = aNext->find(mNext->first, argPos)) != string::npos)
            {
                // if another occurrence in arg found
                // replace it with map value and skip over it
                aNext->replace(argPos, mNext->first.size(), mNext->second);
                argPos += mNext->second.size();
            }
        }
    }

    // build array of args for execution
    char* argArray[MAXARGS + 1];
    argArray[0] = (char*) programInfo.d_path.c_str();
    aNext = programInfo.d_args.begin();
    long    i;
    for (i = 1; aNext != aEnd; ++aNext, ++i)
    {
        argArray[i] = (char*) aNext->c_str();
    }
    argArray[i] = NULL;
    logMessage(MT_INFO, "running", argArray[0]);

    // fork child to execute program
    int     fd[2];
    if (pipe(fd) == -1)
        logMessage(MT_ERROR, "pipe");
    logMessage(MT_INFO, "pipe0", NULL, fd[0]);
    logMessage(MT_INFO, "pipe1", NULL, fd[1]);
    logMessage(MT_INFO, "forking for exec");
    pid_t   childPid = fork();
    if (childPid == -1)
        logMessage(MT_ERROR, "fork");

    // child process
    if (childPid == 0)
    {
        // direct output to pipe
        close(fd[0]);
        dup2(fd[1], fileno(stdout));

        logMessage(MT_INFO, "child for exec");

        // check if program starts in different directory
        // after removing leading "./"
        string  cwd = argArray[0];
        if ((cwd[0] == '.') && (cwd[1] == '/'))
            cwd.erase(0, 2);
        size_t  lastSlash = cwd.find_last_of('/');
        if (lastSlash == string::npos)
            lastSlash = cwd.find_last_of('\\');
        if (lastSlash != string::npos)
        {
            // save and remove program name
            string  progName(cwd, lastSlash);
            cwd.resize(lastSlash);

            // if absolute path not specified, start with current directory
            // absolute path starts with "/" or "x:/" or "x:\"
            const char* path = argArray[0];
            bool        absolutePath =
                   (path[0] == '/')
                || (   isalpha(path[0])
                    && (path[1] == ':')
                    && ((path[2] == '/') || (path[2] == '\\')));
            if (!absolutePath)
            {
                cwd.insert(0, "/");
                cwd.insert(0, getcwd(buffer, BUFSIZE));
            }
            logMessage(MT_INFO, "chdir", cwd.c_str());

            // change to new directory
            if (chdir(cwd.c_str()) == -1)
            {
                // return error msg and log it
                string  errMsg("Cannot change to directory for ");
                errMsg += a_label;
                write(fileno(stdout), errMsg.c_str(), errMsg.size());
                logMessage(MT_ERROR, "chdir", cwd.c_str());
            }

            // build absolute version of executable
            cwd.append(progName);
            argArray[0] = (char*) cwd.c_str();
        }

        // start program
        execv(argArray[0], argArray);
        logMessage(MT_ERROR, "execv", argArray[0]);
    }

    // parent process
    close(fd[1]);

    // wait for child to finish
    logMessage(MT_INFO, "waiting for exec child", NULL, childPid);
    if ((waitpid(childPid, NULL, 0) < 0) && (errno != ECHILD))
        logMessage(MT_ERROR, "wait", NULL, childPid);
    logMessage(MT_INFO, "done waiting");

    // start output using specified type
    sprintf(buffer,
            "HTTP/1.0 200 OK\r\nContent-Type: %s\r\n\r\n",
            programInfo.d_mimeType.c_str());
    write(a_fd, buffer, strlen(buffer));

    // return pipe contents
    long    ret;
    while ((ret = read(fd[0], buffer, BUFSIZE)) > 0)
        write(a_fd, buffer, ret);

#ifdef LINUX
    sleep(1);       /* to allow socket to drain */
#endif
    exit(1);
}

//****************************************************************************
//
//  handleSpecial() - handle special requests
//
//  Parameters:
//      a_request       request to handle
//      a_socketFd      where to return content to requestor
//
//  Return value:
//      ST_CONTINUE     command was recognized and daemon should continue
//      ST_EXIT         command was recognized and daemon should exit
//      ST_NONE         command was not recognized
//
//****************************************************************************
SpecialType handleSpecial(const string& a_request, int a_socketFd)
{
    // my process id
    if (a_request == "mypid")
    {
        char    temp[50];
        write(a_socketFd, f_startPlainText, strlen(f_startPlainText));
        sprintf(temp, "%u\r\n", (unsigned int) getpid());
        write(a_socketFd, temp, strlen(temp));
        logMessage(MT_INFO, "mypid", NULL, getpid());
        return ST_CONTINUE;
    }
    // turn on detailed logging
    else if (a_request == "verbose")
    {
        f_verbose = true;
        logMessage(MT_INFO, "verbose", NULL, getpid());
        return ST_CONTINUE;
    }
    // turn off detailed logging
    else if (a_request == "quiet")
    {
        logMessage(MT_INFO, "quiet", NULL, getpid());
        f_verbose = false;
        return ST_CONTINUE;
    }
    // attach
    else if (a_request == "attach")
    {
        logMessage(MT_INFO, "attaching", NULL, getpid());
        ++f_attachCount;
        return ST_CONTINUE;
    }
    // detach
    else if (a_request == "detach")
    {
        logMessage(MT_INFO, "detaching", NULL, getpid());
        --f_attachCount;

        // if anyone still attached, keep going
        // if this is last attachment, kill daemon
        if (f_attachCount > 0)
            return ST_CONTINUE;
        else
            return ST_EXIT;
    }
    // ref count
    else if (a_request == "refcount")
    {
        char    temp[50];
        write(a_socketFd, f_startPlainText, strlen(f_startPlainText));
        sprintf(temp, "%d\r\n", f_attachCount);
        write(a_socketFd, temp, strlen(temp));
        logMessage(MT_INFO, "refcount", NULL, getpid());
        return ST_CONTINUE;
    }
    // kill self
    else if (a_request == "kill")
    {
        logMessage(MT_INFO, "killing", NULL, getpid());
        return ST_EXIT;
    }

    return ST_NONE;
}

};  // end anonymous namespace


//****************************************************************************
//
//  main() - Main routine
//
//  Parameters:
//      a_argc          number of arguments
//      a_argv          array of pointers to arguments
//
//****************************************************************************
int main(int a_argc, char** a_argv)
{
    // change current dir to where program is running
    string  cwd(a_argv[0]);
    size_t  lastSlash = cwd.find_last_of('/');
    if (lastSlash == string::npos)
        lastSlash = cwd.find_last_of('\\');
    if (lastSlash != string::npos)
    {
        cwd.resize(lastSlash);
        if (chdir(cwd.c_str()) == -1)
        {
            cout << "Can't change to directory " << cwd.c_str() << endl;
            exit(1);
        }
    }

    // check validity of args
    if (a_argc != 2  || (strcmp(a_argv[1], "-?") == 0))
    {
        usage(a_argc, a_argv);
        logMessage(MT_ERROR, "bad args", NULL, a_argc);
    }

    // read configuration file
    readConfig(a_argv[1]);

    // ignore child death, close open files
    signal(SIGCHLD, SIG_IGN);
    for (int i = 0; i < 32; i++)
        close(i);

    // setup the network socket
    int listenFd;
    if ((listenFd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        logMessage(MT_ERROR, "socket");
    int on = 1;
    if (setsockopt(listenFd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0)
        logMessage(MT_ERROR, "setsockopt");
    struct sockaddr_in  servAddr;
    bzero(&servAddr, sizeof(servAddr));
    servAddr.sin_family = AF_INET;
    servAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    servAddr.sin_port = htons(f_port);
    if (bind(listenFd,
             (struct sockaddr*) &servAddr,
             sizeof(servAddr)) < 0)
    {
        logMessage(MT_ERROR, "bind", NULL, f_port);
    }
    if (listen(listenFd, 64) < 0)
        logMessage(MT_ERROR, "listen", NULL, listenFd);

    struct sockaddr_in  cliAddr;
    bzero(&cliAddr, sizeof(cliAddr));
    while (1)
    {
        // accept next request
        socklen_t   length = sizeof(cliAddr);
        int         socketFd;
        if ((socketFd = accept(listenFd,
                               (struct sockaddr*) &cliAddr,
                               &length)) < 0)
        {
            logMessage(MT_ERROR, "accept", NULL, listenFd);
        }
        logMessage(MT_INFO, "accept", NULL, listenFd);

        // read request
        long    len;
        char    buffer[BUFSIZE+1];
        len = read(socketFd, buffer, BUFSIZE);
        if (len == 0 || len == -1)
        {
            logMessage(MT_ERROR,
                       "Failed to read browser request",
                       NULL,
                       0,
                       socketFd);
        }

        // terminate the buffer and make sure it's a GET request
        if (len < 0)
            len = 0;
        if (len > BUFSIZE)
            len = BUFSIZE;
        buffer[len] = '\0';
        if (strncasecmp(buffer, f_GET, strlen(f_GET)))
        {
            errno = 0;
            logMessage(MT_ERROR, "Unsupported operation", buffer, 0, socketFd);
        }

        // string is "GET URL " + extra stuff
        // null terminate after the second space to ignore extra stuff
        for (long i = 4; i < len; ++i)
        {
            if (buffer[i] == ' ')
            {
                len = i;
                break;
            }
        }
        buffer[len] = '\0';
        logMessage(MT_INFO, "request", buffer);

        // start after initial "GET " and slash
        const char* argStart = buffer + strlen(f_GET);
        if (*argStart == '/')
            ++argStart;
        const char* argEnd = buffer + len;
        const char* argDelim = find(argStart, argEnd, '?');
        string      label = decodeURI(argStart, argDelim);
        string      args = decodeURI(argDelim, argEnd);
        strcpy(buffer, label.c_str());
        strcat(buffer, args.c_str());
        logMessage(MT_INFO, "decoded", buffer);

        // check for special requests
        SpecialType special = handleSpecial(label, socketFd);
        if (special == ST_CONTINUE)
        {
            close(socketFd);
            continue;
        }
        else if (special == ST_EXIT)
        {
            close(socketFd);
            break;
        }
        // else handle regularly

        // not special request: fork child to handle it
        int childPid;
        logMessage(MT_INFO, "forking for request");
        if ((childPid = fork()) < 0)
            logMessage(MT_ERROR, "fork");

        // child
        if (childPid == 0)
        {
            logMessage(MT_INFO, "child for request");
            close(listenFd);
            web(socketFd, label, args);
        }
        // parent
        else
        {
            logMessage(MT_INFO, "parent after request");
            close(socketFd);
        }
    }

    return 0;
}
