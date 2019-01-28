public boolean dlPending = false;
BufferedReader reader;
String line;
String link;
String zipName;
Scanner r;
String[] lines = new String[1];
String currentVer;
String repoVer;
String patchNotes = "";
boolean bool;
private String INPUT_ZIP_FILE;
private String OUTPUT_FOLDER;
private String TEMP_FOLDER;
Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
int swidth = (int)screenSize.getWidth();
int sheight = (int)screenSize.getHeight();
JFrame frame;
JPanel pane;
JLayeredPane propane;
JProgressBar jProgressBar = new JProgressBar();
JTextArea texta;
JButton updatebtn = new JButton("Actualizar");
PrintWriter out;

public void tryUpdate()
{
  OUTPUT_FOLDER = System.getProperty("user.dir");
  TEMP_FOLDER = (System.getProperty("java.io.tmpdir") + "/Extended Ping");
  println(TEMP_FOLDER);
  try
  {
    if (getManifestInfo() != null) {
      currentVer = getManifestInfo();
    } else {
      currentVer = "1.9.0";
    }
  }
  catch (NullPointerException localNullPointerException) {}
  try
  {
    r = new Scanner(new URL("https://raw.githubusercontent.com/Trane210/Extended-Ping/master/version.txt")
      .openStream());
    repoVer = r.next();
    dlPending = true;
  }
  catch (IOException e)
  {
    jFrame.setTitle("Extended Ping " + getManifestInfo() + " - By Trane210 | Sin conexión");
    dlPending = false;
    e.printStackTrace();
  }
  println(new Object[] {currentVer, repoVer });
  if ((currentVer != null) && (currentVer.equals(repoVer)))
  {
    checkNotes(0);
  }
  else if (dlPending)
  {
    jFrame.setTitle("Extended Ping " + getManifestInfo() + " - By Trane210 | Hay una actualización pendiente |");
    execBtn.setBounds(706, 524, 93, 40);
    jFrame.getContentPane().add(updatebtn);
    updatebtn.setBounds(799, 524, 93, 40);
    updatebtn.addActionListener(new ActionListener()
    {
      public void actionPerformed(ActionEvent event)
      {
        preDownload();
        updatebtn.setEnabled(false);
      }
    });
  }
}

public void checkNotes(int c)
{
  if ((c == 1) || (!prefs.getBoolean("extendedpingOnupdate", onUpdateDefault))) {
    try
    {
      r = new Scanner(new URL("https://raw.githubusercontent.com/Trane210/Extended-Ping/master/changes.txt")
        .openStream());
      r.useDelimiter("\r\n");
      while (r.hasNext()) {
        patchNotes += r.next();
      }
      r.close();
      JTextArea textArea = new JTextArea(patchNotes);
      patchNotes = "";
      JScrollPane scrollPane = new JScrollPane(textArea);
      textArea.setLineWrap(true);
      textArea.setWrapStyleWord(true);
      scrollPane.setPreferredSize(new Dimension(500, 500));
      
      Object[] options = { "Aceptar" };
      if (JOptionPane.showOptionDialog(null, scrollPane, "Notas de versión", 0, 
        1, null, options, options[0]) == 0) {
        prefs.putBoolean("extendedpingOnupdate", true);
      }
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
}

public void preDownload()
{
  prefs.putBoolean("extendedpingOnupdate", false);
  link = ("https://raw.githubusercontent.com/Trane210/Extended-Ping/master/v" + repoVer + ".zip");
  zipName = ("v" + repoVer + ".zip");
  INPUT_ZIP_FILE = zipName;
  println(OUTPUT_FOLDER);
  download();
}

public void download()
{
  jFrame.setVisible(false);
  
  jProgressBar.setMaximum(100000);
  frame = new JFrame();
  
  frame.addWindowListener(new WindowAdapter()
  {
    public void windowClosing(WindowEvent windowEvent)
    {
      if (bool)
      {
        if (JOptionPane.showConfirmDialog(frame, 
          "Estas seguro?", "", 
          0, 
          3) == 0) {
          System.exit(0);
        }
      }
      else {
        try
        {
          Runtime.getRuntime().exec(new String[] { "cmd", "/c", "xcopy", "/C", "/E", "/I", "/Y", TEMP_FOLDER, OUTPUT_FOLDER, "&&", "rmdir", "/s", "/q", TEMP_FOLDER }, null, new File(TEMP_FOLDER));
          System.exit(0);
        }
        catch (Exception e)
        {
          e.printStackTrace();
        }
      }
    }
  });
  frame.setDefaultCloseOperation(0);
  frame.setSize(300, 140);
  frame.setResizable(false);
  frame.setTitle("Actualizando");
  frame.setLocation(new Point(swidth / 2 - frame.getWidth() / 2, sheight / 2 - frame.getHeight() / 2));
  frame.setVisible(true);
  
  propane = new JLayeredPane();
  propane.setLayout(new GridLayout(0, 1));
  propane.add(jProgressBar);
  
  pane = new JPanel();
  pane.setLayout(new GridLayout(3, 0));
  pane.add(new JLabel("Descargando archivos", 0));
  pane.add(new JLabel(""));
  pane.add(propane, "South");
  
  frame.add(pane);
  
  Runnable updatethread = new Runnable()
  {
    public void run()
    {
      try
      {
        URL url = new URL(link);
        HttpURLConnection httpConnection = (HttpURLConnection)url.openConnection();
        long completeFileSize = httpConnection.getContentLength();
        
        BufferedInputStream in = new BufferedInputStream(httpConnection.getInputStream());
        FileOutputStream fos = new FileOutputStream(
          zipName);
        BufferedOutputStream bout = new BufferedOutputStream(
          fos, 1024);
        byte[] data = new byte['?'];
        long downloadedFileSize = 0L;
        int x = 0;
        while ((x = in.read(data, 0, 1024)) >= 0)
        {
          downloadedFileSize += x;
          bool = true;
          
          final int currentProgress = (int)(downloadedFileSize / completeFileSize * 100000.0D);
          
          SwingUtilities.invokeLater(new Runnable()
          {
            public void run()
            {
              jProgressBar.setValue(currentProgress);
            }
          });
          bout.write(data, 0, x);
        }
        bout.close();
        in.close();
        unZip();
      }
      catch (FileNotFoundException e)
      {
        e.printStackTrace();
      }
      catch (IOException e)
      {
        e.printStackTrace();
      }
    }
  };
  new Thread(updatethread).start();
}

public void unZip()
{
  try
  {
    unzip(INPUT_ZIP_FILE, TEMP_FOLDER);
  }
  catch (IOException e)
  {
    e.printStackTrace();
  }
}

public void unzip(String zipFilePath, String destDirectory)
  throws IOException
{
  pane.remove(0);
  pane.add(new JLabel("Desempaquetando archivos", 0), 0);
  frame.setContentPane(pane);
  
  File destDir = new File(destDirectory);
  if (!destDir.exists()) {
    destDir.mkdir();
  }
  ZipInputStream zipIn = new ZipInputStream(new FileInputStream(zipFilePath));
  
  ZipEntry entry = zipIn.getNextEntry();
  while (entry != null)
  {
    String filePath = destDirectory + File.separator + entry.getName();
    
    pane.remove(1);
    
    texta = new JTextArea(filePath);
    texta.setLineWrap(true);
    texta.setWrapStyleWord(true);
    texta.setOpaque(false);
    
    pane.add(texta, 1);
    
    frame.setContentPane(pane);
    
    println(filePath);
    if (!entry.isDirectory())
    {
      extractFile(zipIn, filePath);
    }
    else
    {
      File dir = new File(filePath);
      dir.mkdir();
    }
    zipIn.closeEntry();
    entry = zipIn.getNextEntry();
  }
  zipIn.close();
  File fzip = new File(INPUT_ZIP_FILE);
  fzip.delete();
  pane.remove(0);
  pane.add(new JLabel("Actualizado", 0), 0);
  frame.setContentPane(pane);
  frame.setTitle("Updated");
  bool = false;
  println("done");
}

private void extractFile(ZipInputStream zipIn, String filePath)
  throws IOException
{
  BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath, false));
  byte[] bytesIn = new byte['?'];
  int read = 0;
  while ((read = zipIn.read(bytesIn)) != -1) {
    bos.write(bytesIn, 0, read);
  }
  bos.close();
}

public static String getManifestInfo()
{
  try
  {
    Enumeration resEnum = Thread.currentThread().getContextClassLoader().getResources("META-INF/MANIFEST.MF");
    while (resEnum.hasMoreElements()) {
      try
      {
        URL url = (URL)resEnum.nextElement();
        InputStream is = url.openStream();
        if (is != null)
        {
          Manifest manifest = new Manifest(is);
          Attributes mainAttribs = manifest.getMainAttributes();
          String version = mainAttribs.getValue("My-Version");
          if (version != null) {
            return version;
          }
        }
      }
      catch (Exception localException) {}
    }
  }
  catch (IOException localIOException) {}
  return null;
}
