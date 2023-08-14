package OTT;

import java.util.Scanner;
import OTT.Methods;

public class Methods
{
  public boolean cmdStatus(String[] cmd, String err)
  {
    try
    {
      Process proc = Runtime.getRuntime().exec(cmd);

      proc.waitFor();
      if(proc.exitValue() != 0)
      {
        int pchar;
        
        while((pchar = proc.getErrorStream().read()) > 0)
          if(err != null)
            err += (char) pchar;
          else
            System.err.print((char) pchar);
        return false;
      }
    }
    catch(Exception e)
    {
      e.printStackTrace();
      System.exit(-1);
    }

    return true;
  }

  public String pause(String msg)
  {
    Scanner pause = new Scanner(System.in);
    String line;

    System.out.print(Main.STD + msg);
    line = pause.nextLine();
    pause.close();

    return line;
  }

  public boolean connect(String ip)
  {
    System.out.println(Main.ORA214 + "Conectando-se à sua TV.");
    String cmd[][] = { { "adb", "disconnect" }, { "adb", "connect", ip + ":5555" },
                       { "adb", "get-state" } },
           err, errscan;
    Scanner scanner;
    boolean unauthorized;
    int i;

    unauthorized = false;
    for(i = 0; i < cmd.length; i++)
    {
      err = "";
      this.cmdStatus(cmd[i], err);

      scanner = new Scanner(err);
      while(scanner.hasNextLine())
      {
        errscan = scanner.nextLine();

        if(errscan.compareTo("error: device unauthorized.") == 0)
        {
          System.out.println(Main.CYA122 + "Apareceu a seguinte janela em sua TV:\n" +
                             Main.BOL + "Permitir a depuração USB?\n" +
                             Main.CYA122 + "Marque a seguinte caixa:\n" +
                             Main.PIN + "Sempre permitir a partir deste computador.\n" +
                             Main.CYA122 + "Selecione OK.\n");
          this.pause("Pressione ENTER para continuar.");
          unauthorized = true;

          break;
        }
        else if(errscan.compareTo("error: no devices/emulators found") == 0)
        {
          scanner.close();
          return false;
        }
      }
      if(unauthorized)
        i = 0;

      scanner.close();
    }

    return true;
  }
}
