package OTT;

import java.io.InputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.File;
import java.net.URL;
import java.net.URI;
import java.util.Scanner;
import java.lang.Runtime;
import OTT.Methods;

public class Main
{
  /* Cores degrade */
  public static final String RED001 = "\033[38;5;1m", /* Vermelho 1 */
  RED009 = "\033[38;5;9m", /* Vermelho 9 */
  CYA122 = "\033[38;5;122m", /* Ciano 122 */
  CYA044 = "\033[38;5;44m", /* Ciano 44 */
  PUR063 = "\033[38;5;63m", /* Roxo 63 */
  PUR027 = "\033[38;5;27m", /* Roxo 27 */
  GRE046 = "\033[38;5;46m", /* Verde 46 */
  GRY247 = "\033[38;5;247m", /* Cinza 247 */
  ORA208 = "\033[38;5;208m", /* Laranja 208 */
  ORA214 = "\033[38;5;214m", /* Laranja 214 */
  YEL226 = "\033[38;5;226m", /* Amarelo 226 */
  BLU039 = "\033[38;5;44m", /* Azul 39 */
  BRW094 = "\033[38;5;94m", /* Marrom 94 */
  BRW136 = "\033[38;5;136m", /* Marrom 136 */

  /* Cores chapadas */
  GRY = "\033[30;1m", /* Cinza */
  RED = "\033[31;1m", /* Vermelho */
  GRE = "\033[32;1m", /* Verde */
  YEL = "\033[33;1m", /* Amarelo */
  BLU = "\033[34;1m", /* Azul */
  PIN = "\033[35;1m", /* Rosa */
  CYA = "\033[36;1m", /* Ciano */
  BOL = "\033[37;1m", /* Negrito */
  WAR = "\033[40;31;5m", /* Vermelho piscando; aviso! */
  STD = "\033[m", /* Fechamento de cor */
  CLR = "\033[2J\033[H",

  path[] = { "/data/data/com.termux/files", System.getenv("HOME"), "/usr" },
  classpath = "OTT.jar",
  cwd = System.getProperty("user.dir");
  public static boolean isAndroid;

  public static void main(String[] args)
  {
    if(((isAndroid = ((path[0] + "/home").compareTo(cwd)) == 0) || path[1].compareTo(cwd) == 0) &&
         classpath.compareTo(System.getProperty("java.class.path")) == 0)
    {
      version();
      init();
      System.exit(0);
    }

    System.err.println("Você deve rodar este aplicativo a partir do diretório HOME.");
    System.exit(-1);
  }

  public static void version()
  {
    System.out.print(CLR);

    try
    {
      String preurl = "https://github.com/Krush206/optimize_android_tv/raw/java";
      URL url = new URI(isAndroid ? preurl + "/OTT_Android.jar" : preurl + "/OTT_Linux.jar").toURL();
      InputStream uin = url.openStream();
      FileReader fin = new FileReader(classpath);
      String app = "", localapp = "";
      int pchar;

      while((pchar = uin.read()) > 0)
        app += (char) pchar;
      uin.close();
      while((pchar = fin.read()) > 0)
        localapp += (char) pchar;
      fin.close();
      if(localapp.hashCode() != app.hashCode())
      {
        FileWriter fout = new FileWriter(classpath);

        System.out.println(BLU + "* " + BOL + "Nova versão encontrada!\n" +
                           BLU + "* " + STD + "Atualizando. Aguarde!");
        fout.write(app);
        fout.close();
        System.out.println(GRE + "* " + BOL + "Atualizado com sucesso!\n\n" + STD +
                           "Reinicie o aplicativo.");
        System.exit(0);
      }
    }
    catch(Exception e)
    {
      e.printStackTrace();
      System.exit(-1);
    }
  }

  public static void init()
  {
    Methods ott = new Methods();
    String ip;

    System.out.println(CLR + BOL + "Bem-vindo(a) ao OTT (Otimização TV TCL)!\n\n" +
                       "Modelos compatíveis:\n" +
                       PIN + "Chassi T221T01 = " + CYA + "S615" + STD + ".\n" +
                       PIN + "Chassi R51AT01 = " + CYA + "P635" + STD + ".\n" +
                       PIN + "Chassi RT41 = " + CYA + "ES560" +
                       STD + ", " + CYA + "S6500" + STD + ", " + CYA + "S5300" + STD + ".\n" +
                       PIN + "Chassi RT51 = " + CYA + "A6" +
                       STD + ", " + CYA + "A8" + STD + ", " + CYA + "A10" +
                       STD + ", " + CYA + "C715" + STD + ", " + CYA + "C716" +
                       STD + ", " + CYA + "C717" + STD + ", " + CYA + "C815" +
                       STD + ", " + CYA + "EP640" + STD + ", " + CYA + "EP645" +
                       STD + ", " + CYA + "EP645" + STD + ", " + CYA + "EP660" +
                       STD + ", " + CYA + "EP685" + STD + ", " + CYA + "EP785" +
                       STD + ", " + CYA + "K61" + STD + ", " + CYA + "P615" +
                       STD + ", " + CYA + "P715" + STD + ", " + CYA + "P717" +
                       STD + ", " + CYA + "P8M/US" + STD + ", " + CYA + "Q800" +
                       STD + ", " + CYA + "X10" + STD + ", " + CYA + "X815" + STD + ".\n" +
                       PIN + "Chassi R51M = " + CYA + "P725" + STD + ", " + CYA + "C725" + STD + ".\n" +
                       PIN + "Chassi T615T01 = " + CYA + "C825" + STD + ".\n" +
                       PIN + "Chassi T615T01/03 = " + CYA + "C825" + STD + ", " + CYA + "C835" + STD + ".\n");

    ott.pause("Pressione ENTER para continuar.");
    System.out.println(PUR063 + "\nVerificando dependências. Aguarde!");

    if(isAndroid)
    {
      System.out.println(BOL + "Você está executando esse script no " + PIN + "Android" + STD + '.');
      if(new File(path[0] + "/usr/bin/fakeroot").exists() &&
         new File(path[0] + "/usr/bin/tput").exists() &&
         new File(path[0] + "/usr/bin/adb").exists())
        System.out.println(GRE046 + "Dependências encontradas!");
      else
      {
        String properties = cwd + "/.termux/termux.properties",
               property = "apt.default_repo=stable",
               cmd[][] = { { "apt", "update" }, { "apt", "upgrade", "-y" },
                           { "apt", "install", "-y", "ncurses-utils", "android-tools", "fakeroot" } };
        int i;
        boolean repoIsSet = false;

        try
        {
          Scanner file = new Scanner(new File(properties));
  
          while(file.hasNextLine())
          {
            String line;

            line = file.nextLine();

            if(line.compareTo(property) == 0)
            {
              repoIsSet = true;
              break;
            }
          }
        }
        catch(Exception e)
        {
          e.printStackTrace();
          System.exit(-1);
        }

	if(!repoIsSet)
        {
          try
          {
            FileReader fin = new FileReader(properties);
            FileWriter fout;
            String raw = "";
            int pchar;

            while((pchar = fin.read()) > 0)
              raw += (char) pchar;
            raw += property;
            fout = new FileWriter(properties);
            fout.write(raw + '\n');
            fout.close();
            fin.close();
          }
          catch(Exception e)
          {
            e.printStackTrace();
            System.exit(-1);
          }
        }

        System.out.println(BLU + "* " + BOL + "Baixando dependências. Aguarde!");
        for(i = 0; i < cmd.length; i++)
          if(!ott.cmdStatus(cmd[i], null))
            System.exit(-1);

	System.out.println(GRE + "Dependências instaladas com sucesso!");
      }
    }
    else
    {
      System.out.println(BOL + "Você está executando esse script no " + PIN + "Linux" + STD + '.');
      if(new File(path[2] + "/bin/adb").exists())
        System.out.println(GRE046 + "Dependência encontrada!");
      else
      {
        System.err.println(PUR063 + "Dependência faltando. Instale o ADB e tente novamente.");
        System.exit(-1);
      }
    }

    System.out.println(GRE046 + "Prepare-se para conectar à TV.\n");
    ip = ott.pause(STD + "O endereço IP da sua TV pode ser encontrado no caminho abaixo:\n" +
                   YEL226 + "Configurações\n" +
                   "Preferências do dispositivo\n" +
                   "Sobre\n\n" +
                   STD + "Insira o endereço IP da TV: ");
    while(true)
    {
      if(ott.connect(ip))
        break;
      ip = ott.pause(CLR + RED + "Endereço IP inválido." +
                     STD + "Insira o endereço IP da TV: ");
    }
  }
}
