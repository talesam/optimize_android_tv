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
import java.io.DataInputStream;
import java.lang.reflect.Array;
import OTT.Methods;

public class Methods extends Object
{
  public String errmut = "";

  public boolean cmdStatus(String[] cmd, boolean print)
  {
    try
    {
      Process proc = Runtime.getRuntime().exec(cmd);

      proc.waitFor();
      if(proc.exitValue() != 0)
      {
        DataInputStream procerr = new DataInputStream(proc.getErrorStream());
        Object err = Array.newInstance(byte.class, procerr.available());

        procerr.readFully((byte[]) err);
        errmut = new String((byte[]) err);
        if(print)
          System.err.print(errmut);
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

    return line;
  }

  public boolean connect(String ip)
  {
    String cmd[][] = { { "adb", "disconnect" }, { "adb", "connect", ip + ":5555" },
                       { "adb", "get-state" } },
           errscan;
    Scanner scanner;
    int i;

    System.out.println(Main.ORA214 + "\nConectando-se à sua TV.\n");

    for(i = 0; i < cmd.length; i++)
    {
      cmdStatus(cmd[i], false);

      scanner = new Scanner(errmut);
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
          pause("Pressione ENTER para continuar.");
          i = 0;

          break;
        }
        else if(errscan.compareTo("error: no devices/emulators found") == 0)
        {
          scanner.close();
          return false;
        }
      }

      scanner.close();
    }

    return true;
  }
}
