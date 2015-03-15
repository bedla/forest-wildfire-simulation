import org.nlogo.api.Argument ;
import org.nlogo.api.Context ;
import org.nlogo.api.ExtensionException ;
import org.nlogo.api.LogoException ;
import org.nlogo.api.Syntax ;
import org.nlogo.api.DefaultCommand;


public class SchemeDialog extends DefaultCommand
{
	public Syntax getSyntax()
	{
		return Syntax.commandSyntax
			( new int[] { } ) ;
	}
	public String getAgentClassString()
	{
		return "OTPL" ;
	}	
	public void perform( Argument args[] , Context context )
		throws ExtensionException, LogoException
	{
		ColorSchemesDialog csd = new ColorSchemesDialog(null, false);
		csd.showDialog();
	}
}

