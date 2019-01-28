ArrayList<String> pingResult = new ArrayList();
ArrayList<Integer> pingCalc = new ArrayList();
Clip timeOutSound;
Clip minPingSound;
BooleanControl timeOutMute;
BooleanControl minPingMute;
boolean trydebug = false;
boolean scrollBarAtBottom;

int ping;

public class pingClass implements Runnable {  
  public void run()
  {
    if (!Thread.interrupted())
    {
      String ip = ipOne.getText();// + "." + ipTwo.getText() + "." + ipThree.getText() + "." + ipFour.getText();
      
      String load = byteText.getText();
      
      int timeout = parseInt(timeOut.getText());
      prefs.put("extendedpingTimeout", timeOut.getText());
      
      ArrayList<Integer> pingCalc = new ArrayList();
      
      int timeOutCounter = 0;
      
      int pingCount = 0;
      
      String pingCmd = "ping -t " + (timeOut.getText().equals("") ? "-w 4000 " : "-w " + (timeout * 1000) + " ") + (byteText.getText().equals("") ? "-l 1 " : new StringBuilder("-l ").append(load).append(" ").toString()) + ip;
      println(pingCmd);
      try
      {
        try
        {
          timeOutSound = AudioSystem.getClip();
          timeOutSound.open(AudioSystem.getAudioInputStream(getClass().getResource("/data/beepbeep.wav")));
          timeOutMute = ((BooleanControl)timeOutSound.getControl(BooleanControl.Type.MUTE));
          minPingSound = AudioSystem.getClip();
          minPingSound.open(AudioSystem.getAudioInputStream(getClass().getResource("/data/goatscream.wav")));
          minPingMute = ((BooleanControl)minPingSound.getControl(BooleanControl.Type.MUTE));
          println("jar sounds");
        }
        catch (Exception ex)
        {
          trydebug = true;println("not a jar, trying debug");
        }
        if (trydebug) {
          try
          {
            timeOutSound = AudioSystem.getClip();
            timeOutSound.open(AudioSystem.getAudioInputStream(new File("C:/Users/trane/Desktop/beepbeep.wav")));
            timeOutMute = ((BooleanControl)timeOutSound.getControl(BooleanControl.Type.MUTE));
            minPingSound = AudioSystem.getClip();
            minPingSound.open(AudioSystem.getAudioInputStream(new File("C:/Users/trane/Desktop/goatscream.wav")));
            minPingMute = ((BooleanControl)minPingSound.getControl(BooleanControl.Type.MUTE));
            println("debug sounds");
          }
          catch (Exception ex) {}
        }
        if (prefs.getBoolean("extendedpingMute", muteDefault))
        {
          if (timeOutMute != null) {
            timeOutMute.setValue(true);
          }
          if (minPingMute != null) {
            minPingMute.setValue(true);
          }
        }
        else
        {
          if (timeOutMute != null) {
            timeOutMute.setValue(false);
          }
          if (minPingMute != null) {
            minPingMute.setValue(false);
          }
        }
        Runtime r = Runtime.getRuntime();
        Process p = r.exec(pingCmd);
        
        BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
        String inputLine;
        while ((inputLine = in.readLine()) != null)
        {
          pingResult.add(new Date() + " [PING] " + inputLine);
          
          try {
            ping = parseInt(inputLine.split("tiempo")[1].split("=")[1].split("ms")[0]);
          } catch (Exception e) { println("Could not get ping from '" + inputLine + "', probably ignore?"); }
          
          if (inputLine.matches("Tiempo de espera agotado para esta solicitud."))
          {
            try
            {
              lastPings.getDocument().insertString(lastPings.getDocument().getLength(), "\nTIME\nOUT", redStyle);
            }
            catch (Exception ex) {}
            timeOutSound.stop();
            timeOutSound.flush();
            timeOutSound.setFramePosition(0);
            timeOutSound.start();
            timeOutCounter++;
            timeOutCount.setText("Tiempos de espera agotados: " + timeOutCounter);
          }
          try
          {
            if(inputLine.isEmpty() || inputLine.contains("Haciendo ping a")) {}
            
            else {
            
              if ((minPing != 0) && ping >= minPing)
              {
                minPingSound.stop();
                minPingSound.flush();
                minPingSound.setFramePosition(0);
                minPingSound.start();
              }
  
              pingCalc.add(ping);
              
              if (pingCalc.size() != 0)
              {
                try
                {
                  if (!prefs.getBoolean("extendedpingOverlaylimitping", ovLimitPingDefault))
                  {
                    if (minPing != 0)
                    {
                      if ((pingCalc.get(pingCalc.size() - 1)) < lowMinPing) {
                        lastPings.getDocument().insertString(lastPings.getDocument().getLength(), "\n" + str((pingCalc.get(pingCalc.size() - 1))), whiteStyle);
                      }
                      if (((pingCalc.get(pingCalc.size() - 1)) >= lowMinPing) && ((pingCalc.get(pingCalc.size() - 1)).intValue() < midMinPing)) {
                        lastPings.getDocument().insertString(lastPings.getDocument().getLength(), "\n" + str((pingCalc.get(pingCalc.size() - 1))), yellowStyle);
                      }
                      if (((pingCalc.get(pingCalc.size() - 1)) >= midMinPing) && ((pingCalc.get(pingCalc.size() - 1)).intValue() < minPing)) {
                        lastPings.getDocument().insertString(lastPings.getDocument().getLength(), "\n" + str((pingCalc.get(pingCalc.size() - 1))), orangeStyle);
                      }
                      if ((pingCalc.get(pingCalc.size() - 1)) >= minPing) {
                        lastPings.getDocument().insertString(lastPings.getDocument().getLength(), "\n" + str((pingCalc.get(pingCalc.size() - 1))), redStyle);
                      }
                    }
                    else
                    {
                      lastPings.getDocument().insertString(lastPings.getDocument().getLength(), "\n" + str(pingCalc.get(pingCalc.size() - 1)), whiteStyle);
                    }
                  }
                  else if (pingCalc.get(pingCalc.size() - 1) >= minPing) {
                    lastPings.getDocument().insertString(lastPings.getDocument().getLength(), "\n" + str(pingCalc.get(pingCalc.size() - 1)), redStyle);
                  }
                }
                catch (Exception e)
                {
                  e.printStackTrace();
                }
                println(Integer.valueOf(lowMinPing), Integer.valueOf(midMinPing), Integer.valueOf(minPing));
                lastPings.setCaretPosition(lastPings.getDocument().getLength() - 1);
              }
              pingMath.setText("Minimo: " + getMinValue(pingCalc) + 
                " | Maximo: " + getMaxValue(pingCalc) + 
                " | Media: " + (int)getMeanValue(pingCalc));
            }
          }
          catch (ArrayIndexOutOfBoundsException ex) { ex.printStackTrace(); }
          if ((!inputLine.matches("")) && (!inputLine.contains("Haciendo ping"))) {
            try
            {
              if (inputLine.matches("Tiempo de espera agotado para esta solicitud.")) {
                textArea.append(new Date() + " [TIMEOUT] " + inputLine + "\n");
              } else if ((minPing != 0) && (ping >= minPing)) {
                textArea.append(new Date() + " [WARN] " + inputLine + "\n");
              } else {
                textArea.append(new Date() + " [PING] " + inputLine + "\n");
              }
              BoundedRangeModel model = scroll.getVerticalScrollBar().getModel();
              scrollBarAtBottom = (model.getExtent() + model.getValue() == model.getMaximum());
              if (scrollBarAtBottom) {
                textArea.setCaretPosition(textArea.getDocument().getLength());
              }
              if (http)
              {
                if (((Integer)pingCalc.get(pingCalc.size() - 1)).intValue() < lowMinPing) {
                  h.send(LocalTime.now() + " | " + inputLine + "<br>", 0);
                }
                if ((((Integer)pingCalc.get(pingCalc.size() - 1)).intValue() >= lowMinPing) && (((Integer)pingCalc.get(pingCalc.size() - 1)).intValue() < midMinPing)) {
                  h.send(LocalTime.now() + " | " + inputLine + "<br>", 1);
                }
                if ((((Integer)pingCalc.get(pingCalc.size() - 1)).intValue() >= midMinPing) && (((Integer)pingCalc.get(pingCalc.size() - 1)).intValue() < minPing)) {
                  h.send(LocalTime.now() + " | " + inputLine + "<br>", 2);
                }
                if (((Integer)pingCalc.get(pingCalc.size() - 1)).intValue() >= minPing) {
                  h.send(LocalTime.now() + " | " + inputLine + "<br>", 3);
                }
              }
              pingCount++;
            }
            catch (Exception ex)
            {
              //ex.printStackTrace();
            }
          }
          pingTotal.setText("Pings totales: " + pingCount);
        }
        in.close();
      }
      catch (IOException ex) {}
    }
    else {}
  }
}

public static int getMaxValue(ArrayList<Integer> numbers)
{
  int maxValue = numbers.get(0);
  for (int i = 1; i < numbers.size(); i++) {
    if (numbers.get(i) > maxValue) {
      maxValue = numbers.get(i);
    }
  }
  return maxValue;
}

public static int getMinValue(ArrayList<Integer> numbers)
{
  int minValue = numbers.get(0);
  for (int i = 0; i < numbers.size(); i++) {
    if (numbers.get(i) != 0 && numbers.get(i) < minValue) {
      minValue = numbers.get(i);
    }
  }
  return minValue;
}

public static double getMeanValue(ArrayList<Integer> numbers)
{
  double sum = 0.0D;
  for (int i = 0; i < numbers.size(); i++) {
    sum += numbers.get(i);
  }
  return sum / numbers.size();
}
