/*
 * Copyright (c) 2023 Matheus Garcia.  All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * 3. Neither the name of the author nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

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
