import org.nlogo.api.Argument ;
import org.nlogo.api.Context ;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException ;
import org.nlogo.api.LogoException ;
import org.nlogo.api.LogoList ;
import org.nlogo.api.Syntax ;

// TODO: Check cache handling

public class ScaleScheme extends DefaultReporter
{

	static LogoList list;
	
	public Syntax getSyntax()
	{
		int[] right = { Syntax.TYPE_STRING ,
				Syntax.TYPE_STRING ,
				Syntax.TYPE_NUMBER ,
				Syntax.TYPE_NUMBER ,
				Syntax.TYPE_NUMBER ,
				Syntax.TYPE_NUMBER } ;
		int ret = Syntax.TYPE_LIST ;
		return Syntax.reporterSyntax( right , ret ) ;
	}

	
	public Object report( Argument args[] , Context context )
			throws ExtensionException
	{
		String schemename;
		String legendname;
		int size;
		double var;
		double min;
		double max;
		try
		{
			schemename = args[ 0 ].getString();
			legendname = args[ 1 ].getString();
			size = args[ 2 ].getIntValue();
			var  = args[ 3 ].getDoubleValue();
			min  = args[ 4 ].getDoubleValue();
			max  = args[ 5 ].getDoubleValue();
		}
		catch( LogoException e )
		{
			throw new ExtensionException( e.getMessage() ) ;
		}
		
		int index = 0;
		int [][] legend;

		double perc = 0.0 ;
		if( min > max )      // min and max are really reversed
		{
			if( var < max)
			{
				perc = 1.0 ;
			}
			else if ( var > min )
			{
				perc = 0.0 ;
			}
			else
			{
				double tempval = min - var ;
				double tempmax = min - max;
				perc = tempval / tempmax ;
			}
		}
		else
		{
			if( var > max )
			{
				perc = 1.0 ;
			}
			else if ( var < min ) 
			{
				perc = 0.0 ;
			}
			else
			{
				double tempval = var - min ;
				double tempmax = max - min ;
				perc = tempval / tempmax ;
			}
		}
		index = (int) Math.ceil((perc * (size - 1))) ;		
		
		legend = ColorSchemes.getRGBArray(schemename, legendname, size);
		
		list = new LogoList() ;
		try 
		{
			list.add(new Double (legend[index][0])) ;
			list.add(new Double (legend[index][1])) ;
			list.add(new Double (legend[index][2])) ;
		}
		catch (ArrayIndexOutOfBoundsException e) 
		{
			throw new ExtensionException( 
					"The number of colors in a scheme is limited to " +
					String.valueOf(ColorSchemes.getRGBArray( schemename , legendname ).length) +
					" but your third argument is " + size) ;
		}
		catch (NullPointerException e) 
		{
			throw new ExtensionException( 
					
					"The number of colors in a scheme is limited to " +
					String.valueOf(ColorSchemes.getRGBArray( schemename , legendname ).length) +
					" but your third argument is " + size) ;
		}
		
		return list ;
	}
}
