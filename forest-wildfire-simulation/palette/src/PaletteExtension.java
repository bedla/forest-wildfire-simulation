import org.nlogo.api.DefaultClassManager;
import org.nlogo.api.PrimitiveManager;

public class PaletteExtension extends DefaultClassManager {
    public void load(PrimitiveManager primitiveManager) {
    	//Scale gradient for only 2 colors is in the process of being depreciated
        //primitiveManager.addPrimitive ("scale-gradient", new ScaleGradient());
        primitiveManager.addPrimitive ("scale-gradient", new ScaleGradient());
        primitiveManager.addPrimitive ("scale-scheme", new ScaleScheme());
        primitiveManager.addPrimitive ("scheme-colors", new SchemeColors());
        primitiveManager.addPrimitive ("scheme-dialog", new SchemeDialog());
    }
}
