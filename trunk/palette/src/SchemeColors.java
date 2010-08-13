import org.nlogo.api.Argument ;
import org.nlogo.api.Context ;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException ;
import org.nlogo.api.LogoException ;
import org.nlogo.api.LogoList ;
import org.nlogo.api.Syntax ;

//TODO: Check cache handling

public class SchemeColors extends DefaultReporter
{

	static LogoList list;
	
	public Syntax getSyntax()
	{
		int[] right = {
				Syntax.TYPE_STRING ,
				Syntax.TYPE_STRING ,
				Syntax.TYPE_NUMBER ,
		} ;
		int ret = Syntax.TYPE_LIST ;
		return Syntax.reporterSyntax( right , ret ) ;
	}
	
	public Object report( Argument args[] , Context context )
			throws ExtensionException
	{
		String schemename;
		String legendname;
		int size;
		try
		{
			schemename = args[ 0 ].getString();
			legendname = args[ 1 ].getString();
			size = args[ 2 ].getIntValue();
		}
		catch( LogoException e )
		{
			throw new ExtensionException( e.getMessage() ) ;
		}
		int index = 0;
		int [][] legend;
		
		legend = ColorSchemes.getRGBArray(schemename, legendname, size);

		list = new LogoList();
		LogoList rgblist = null;
		for (int i = 0 ; i < legend.length; i++)
		{
			rgblist = new LogoList() ;
			rgblist.add(new Double (legend[i][0])) ;
			rgblist.add(new Double (legend[i][1])) ;
			rgblist.add(new Double (legend[i][2])) ;
			list.add(rgblist);
		}
		return list ;
	}
}
