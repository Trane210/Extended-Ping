boolean http = false;

public class http implements Runnable {
  Socket clientSocket = null;
  ServerSocket serverSocket = null;
  
  public void start()
  {
    try
    {
      println("trying to listen on port 80");
      serverSocket = new ServerSocket(1337);
      serverSocket.setReuseAddress(true);
      serverSocket.setPerformancePreferences(2, 1, 0);
      println("Listening on port: " + serverSocket.getLocalPort());
    }
    catch (IOException e)
    {
      e.printStackTrace();
      System.err.println("Could not listen on port: 80");
    }
  }
  
  public void run()
  {
    println(serverSocket);
    while (http) {
      try
      {
        clientSocket = serverSocket.accept();
        
        out = new PrintWriter(clientSocket.getOutputStream());
        if (clientSocket != null)
        {
          System.out.println("Connected");
          out.println("HTTP/1.1 200 OK");
          out.println("Content-Type: text/html");
          out.println("\r\n");
          out.println("<head><meta name='viewport' content='width=device-width, initial-scale=1, user-scalable=no'><style type='text/css'>div.normal { color: white; font-family: Calibri; font-size: 2.6vw }</style></head><div id='container' style='background-color: white;'><div id='ping' class='normal' style='background-color: black; height: 94.5%; width: 100%; border: 0px; overflow: auto; position: fixed; top: 0; left: 0;'><script type='text/javascript'>window.setInterval(function() {var elem = document.getElementById('ping');elem.scrollTop = elem.scrollHeight;}, 1000);</script></div><div id='minmaxping' style='background-color: black; height: 5%; width: 100%; border: 0px solid #ccc; font: 2.2vw Georgia, Garamond, Serif; color: white; overflow: auto; position: fixed; bottom: 0; left: 0'></div>");
          
          out.flush();
        }
      }
      catch (Exception e)
      {
        e.printStackTrace();
        System.err.println("Accept failed.");
        try
        {
          Thread.sleep(5000L);
        }
        catch (Exception localException1) {}
      }
    }
    try
    {
      clientSocket.close();
    }
    catch (Exception localException2) {}
    clientSocket = null;
  }
  
  public void close()
  {
    try
    {
      send(LocalTime.now() + " | Conexión cerrada.", 1);
      out.close();
      clientSocket.close();
    }
    catch (Exception localException) {}
    clientSocket = null;
  }
  
  public void send(String msg, int pingKind)
  {
    try
    {
      if (pingKind == 0) {
        out.println("<script>var div = document.getElementById('ping');var c = document.createElement('span');c.innerHTML = '" + 
        
          msg.split("<br>")[0] + "';" + 
          "c.style.color = '#FFFFFF';" + 
          "div.appendChild(c);" + 
          "div.appendChild(document.createElement('br'));" + 
          
          "var divminmax = document.getElementById('minmaxping');" + 
          "divminmax.innerHTML = '" + pingMath.getText() + " - " + pingTotal.getText() + " - " + timeOutCount.getText() + "';</script>");
      }
      if (pingKind == 1) {
        out.println("<script>var div = document.getElementById('ping');var c = document.createElement('span');c.innerHTML = '" + 
        
          msg.split("<br>")[0] + "';" + 
          "c.style.color = '#FFFF00';" + 
          "div.appendChild(c);" + 
          "div.appendChild(document.createElement('br'));" + 
          
          "var divminmax = document.getElementById('minmaxping');" + 
          "divminmax.innerHTML = '" + pingMath.getText() + " - " + pingTotal.getText() + " - " + timeOutCount.getText() + "';</script>");
      }
      if (pingKind == 2) {
        out.println("<script>var div = document.getElementById('ping');var c = document.createElement('span');c.innerHTML = '" + 
        
          msg.split("<br>")[0] + "';" + 
          "c.style.color = '#FFA500';" + 
          "div.appendChild(c);" + 
          "div.appendChild(document.createElement('br'));" + 
          
          "var divminmax = document.getElementById('minmaxping');" + 
          "divminmax.innerHTML = '" + pingMath.getText() + " - " + pingTotal.getText() + " - " + timeOutCount.getText() + "';</script>");
      }
      if (pingKind == 3) {
        out.println("<script>var div = document.getElementById('ping');var c = document.createElement('span');c.innerHTML = '" + 
        
          msg.split("<br>")[0] + "';" + 
          "c.style.color = '#FF0000';" + 
          "div.appendChild(c);" + 
          "div.appendChild(document.createElement('br'));" + 
          
          "var divminmax = document.getElementById('minmaxping');" + 
          "divminmax.innerHTML = '" + pingMath.getText() + " - " + pingTotal.getText() + " - " + timeOutCount.getText() + "';</script>");
      }
      if (pingKind == 4) {
        out.println("<script>var div = document.getElementById('ping');var c = document.createElement('span');c.innerHTML = '" + 
        
          msg.split("<br>")[0] + "';" + 
          "c.style.color = '#AAAAFF';" + 
          "div.appendChild(c);" + 
          "div.appendChild(document.createElement('br'));" + 
          
          "var divminmax = document.getElementById('minmaxping');" + 
          "divminmax.innerHTML = '" + pingMath.getText() + " - " + pingTotal.getText() + " - " + timeOutCount.getText() + "';</script>");
      }
      out.flush();
    }
    catch (Exception localException) {}
  }
}
