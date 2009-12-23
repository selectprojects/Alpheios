package net.alpheios.log4j.spi;
import org.apache.log4j.Level;
import org.apache.log4j.spi.LoggingEvent;
import org.apache.log4j.spi.TriggeringEventEvaluator;

public class InfoTriggerEvaluator implements TriggeringEventEvaluator 
{

	public boolean isTriggeringEvent(LoggingEvent event) 
	{ 
		return event.getLevel().isGreaterOrEqual(Level.INFO); 
	}	
}
