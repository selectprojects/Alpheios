package net.alpheios.log4j.spi;
import org.apache.log4j.Level;
import org.apache.log4j.spi.LoggingEvent;
import org.apache.log4j.spi.TriggeringEventEvaluator;

public class WarnTriggerEvaluator implements TriggeringEventEvaluator 
{

	public boolean isTriggeringEvent(LoggingEvent event) 
	{ 
		String[] thrown = event.getThrowableStrRep();
		boolean showError = true;
		for (int i=0; i<thrown.length;i++) {
			if (thrown[i].matches("EOFException(java.net.SocketException: Broken pipe)") ||
				// this error is often caused by googlebot dropping the ? before the params
				// in the request
			    thrown[i].matches(".*java.lang.IllegalArgumentException.*"))
			{
				showError = false;
				break;
			}
		}
		return 
			showError && event.getLevel().isGreaterOrEqual(Level.WARN); 
	}	
}
