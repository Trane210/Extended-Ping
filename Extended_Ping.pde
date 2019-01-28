import com.sun.awt.AWTUtilities;
import java.awt.Checkbox;
import java.awt.Color;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.GridLayout;
import java.awt.Image;
import java.awt.Point;
import java.awt.PopupMenu;
import java.awt.SystemTray;
import java.awt.Toolkit;
import java.awt.TrayIcon;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.URL;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.Scanner;
import java.util.jar.Attributes;
import java.util.jar.Manifest;
import java.util.prefs.Preferences;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javax.accessibility.AccessibleContext;
import javax.imageio.ImageIO;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.BooleanControl;
import javax.sound.sampled.BooleanControl.Type;
import javax.sound.sampled.Clip;
import javax.swing.BoundedRangeModel;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JCheckBoxMenuItem;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JProgressBar;
import javax.swing.JScrollBar;
import javax.swing.JScrollPane;
import javax.swing.JSlider;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.JTextPane;
import javax.swing.JWindow;
import javax.swing.SwingUtilities;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.text.Document;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.Style;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyleContext;
import processing.core.PApplet;
import processing.core.PSurface;

Thread ayy = null;
Thread httpThr = null;
boolean exec = false;
boolean limiter = false;
int minPing = 0;
int lowMinPing = round(0.3333F * minPing);
int midMinPing = round(0.6666F * minPing);

JFrame jFrame = new JFrame("Extended Ping " + getManifestInfo() + " - By Trane210");
final JFrame confirm = new JFrame();

JMenuBar menuBar = new JMenuBar();
JMenu menu = new JMenu("Opciones");
JCheckBoxMenuItem cbMenuItem = new JCheckBoxMenuItem("No volver a preguntar");
JCheckBoxMenuItem muteCbItem = new JCheckBoxMenuItem("Mute");

JMenuItem versionsMenuItem = new JMenuItem("Notas de versión");
JMenuItem exitMenuItem = new JMenuItem("Salir");

JCheckBox ovCb = new JCheckBox("Overlay");
JCheckBox httpCb = new JCheckBox("Enviar por HTTP?");

JMenuItem ovExitMenuItem = new JMenuItem("Salir");

final Checkbox cb = new Checkbox();

JButton execBtn = new JButton("Ejecutar");
JButton minBtn = new JButton("Aviso de Ping");
JButton logBtn = new JButton("Guardar Log");

JTextArea textArea = new JTextArea(34, 60);
JScrollPane scroll = new JScrollPane(textArea);
JTextPane lastPings = new JTextPane();
JScrollPane lastPingsScroll = new JScrollPane(lastPings);

JLabel ipLabel = new JLabel("IP");
JLabel byteLabel = new JLabel("Bytes");
JLabel timeOutLabel = new JLabel("Tiempo de espera (en segundos)");
JLabel opacityLabel = new JLabel("Opacidad");
JLabel timerLabel = new JLabel("Tiempo: 00:00:00");
JLabel pingTotal = new JLabel("Pings totales: 0");
JLabel timeOutCount = new JLabel("Tiempos de espera agotados: 0");
JLabel pingMath = new JLabel("Minimo: 0 | Maximo: 0 | Media: 0");
JLabel numLineLabel = new JLabel("Nº de lineas");

JTextField ipOne = new JTextField();
/*JTextField ipTwo = new JTextField();
JTextField ipThree = new JTextField();
JTextField ipFour = new JTextField();*/
JTextField limitPing = new JTextField();
JTextField timeOut = new JTextField();
JTextField byteText = new JTextField();

JComboBox numLineCombo;
JSlider ovOpacity = new JSlider(1, 0, 255, 128);
int startTime;
int currentTime;
boolean time = str(currentTime).length() == 0;
boolean trayDialogBool;

Preferences prefs = Preferences.userRoot().node("tr4.j3/extended-ping");
final String prefOnClose = "extendedpingOnclose", onCloseDefault = "none";
final String prefMute = "extendedpingMute"; boolean muteDefault = false;
final String prefOverlay = "extendedpingOverlay"; boolean overlayDefault = true;
final String prefNumOfLines = "extendedpingOverlayNumoflines"; int ovNumLineDefault = 10;
final String prefOvOpacity = "extendedpingOverlayOpacity"; int ovOpacityDefault = 127;
final String prefOvPos = "extendedpingOverlayPos", ovPosDefault = "30,30";
final String prefTimeOut = "extendedpingTimeout", timeOutDefault = "";
final String prefOvLimitPing = "extendedpingOverlaylimitping"; boolean ovLimitPingDefault = false;
final String prefOnUpdate = "extendedpingOnupdate"; boolean onUpdateDefault = false;

boolean mute = false;

final JPopupMenu ovPopUp = new JPopupMenu();
JCheckBoxMenuItem ovLimitPingCb = new JCheckBoxMenuItem("Mostrar solo pings > " + minPing);
JMenuItem ovDisable = new JMenuItem("Deshabilitar overlay");
final PopupMenu popup = new PopupMenu();
TrayIcon trayIcon;
final SystemTray tray = SystemTray.getSystemTray();
public static ArrayList<Image> appIcon = new ArrayList();

boolean trayIconBool = false;
boolean tryDebugIcon = false;

Overlay ov = new Overlay();
http h = new http();

StyleContext sc = new StyleContext();
SimpleAttributeSet attribs = new SimpleAttributeSet();

Style defaultStyle = sc.getStyle("default");
final Style whiteStyle = sc.addStyle("whiteStyle", defaultStyle);
final Style yellowStyle = sc.addStyle("yellowStyle", defaultStyle);
final Style orangeStyle = sc.addStyle("orangeStyle", defaultStyle);
final Style redStyle = sc.addStyle("redStyle", defaultStyle);

int updateStartTime = millis();
int updateTimer;

public void setup()
{
  surface.setLocation(-90000, -90000);
  surface.setVisible(false);
  
  h.start();
  
  StyleConstants.setForeground(whiteStyle, new Color(255, 255, 255, 255));
  StyleConstants.setForeground(yellowStyle, new Color(255, 255, 0, 255));
  StyleConstants.setForeground(orangeStyle, new Color(255, 128, 0, 255));
  StyleConstants.setForeground(redStyle, new Color(255, 0, 0, 255));
  StyleConstants.setAlignment(attribs, 1);
  for (int i = 0; i <= 55; i++)
  {
    try
    {
      appIcon.add(ImageIO.read(getClass().getResource("/data/images/" + i + ".png")));
    }
    catch (Exception localException1)
    {
      tryDebugIcon = true;
    }
    if (tryDebugIcon) {
      try
      {
        appIcon.add(ImageIO.read(new File(
          "C:/Users/trane/Documents/Processing/Extended_Ping/data/images/" + i + ".png")));
      }
      catch (Exception localException2) {}
    }
  }
  try
  {
    URL url = getClass().getResource("/data/images/running.gif");
    
    trayIcon = new TrayIcon(Toolkit.getDefaultToolkit().createImage(url), 
      "Extended Ping " + getManifestInfo());
  }
  catch (Exception localException3)
  {
    tryDebugIcon = true;
  }
  if (tryDebugIcon) {
    try
    {
      trayIcon = new TrayIcon(Toolkit.getDefaultToolkit().createImage(
        "C:/Users/trane/Documents/Processing/Extended_Ping/data/images/running.gif"), 
        "Extended Ping " + getManifestInfo());
    }
    catch (Exception localException4) {}
  }
  IconAnimator animator = new IconAnimator(jFrame, appIcon, 10L);
  animator.start();
  
  popup.add("Salir");
  popup.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      if (e.getActionCommand().equals("Salir"))
      {
        try
        {
          Runtime.getRuntime().exec("taskkill /F /IM PING.EXE");
        }
        catch (Exception localException) {}
        System.exit(0);
      }
    }
  });
  try
  {
    trayIcon.setPopupMenu(popup);
    trayIcon.addMouseListener(new MouseAdapter()
    {
      public void mouseClicked(MouseEvent evt)
      {
        if (evt.getClickCount() >= 2)
        {
          jFrame.setVisible(true);
          jFrame.toFront();
        }
      }
    });
    tray.add(trayIcon);
  }
  catch (Exception localException5) {}
  if (!SystemTray.isSupported()) {
    System.out.println("SystemTray is not supported");
  }
  if (prefs.getBoolean("extendedpingOverlay", overlayDefault))
  {
    ov.setVis(true);
    ovOpacity.setEnabled(true);
    ovCb.setSelected(true);
  }
  else
  {
    ov.setVis(false);
    ovOpacity.setEnabled(false);
    ovCb.setSelected(false);
    println("lmao");
  }
  if (prefs.get("extendedpingOnclose", onCloseDefault).equals("none"))
  {
    cbMenuItem.setEnabled(false);
  }
  else
  {
    cbMenuItem.setState(true);
    trayDialogBool = true;
  }
  if (prefs.getBoolean("extendedpingOverlaylimitping", ovLimitPingDefault)) {
    ovLimitPingCb.setState(true);
  } else {
    ovLimitPingCb.setState(false);
  }
  if (prefs.getBoolean("extendedpingMute", muteDefault)) {
    muteCbItem.setState(true);
  } else {
    muteCbItem.setState(false);
  }
  ov.updateVars(prefs.getInt("extendedpingOverlayOpacity", ovOpacityDefault));
  ovOpacity.setValue(prefs.getInt("extendedpingOverlayOpacity", ovOpacityDefault));
  
  frameRate(10.0F);
  
  thread("tryUpdate");
  
  jFrame.setLayout(null);
  jFrame.setPreferredSize(new Dimension(900, 620));
  jFrame.setResizable(false);
  
  jFrame.getContentPane().add(opacityLabel);
  jFrame.getContentPane().add(ovOpacity);
  
  jFrame.getContentPane().add(ovCb);
  jFrame.getContentPane().add(httpCb);
  jFrame.getContentPane().add(scroll);
  
  jFrame.getContentPane().add(execBtn);
  jFrame.getContentPane().add(minBtn);
  jFrame.getContentPane().add(logBtn);
  
  jFrame.getContentPane().add(ipLabel);
  jFrame.getContentPane().add(byteLabel);
  jFrame.getContentPane().add(pingMath);
  jFrame.getContentPane().add(timeOutLabel);
  jFrame.getContentPane().add(numLineLabel);
  
  jFrame.getContentPane().add(ipOne);
  /*jFrame.getContentPane().add(ipTwo);
  jFrame.getContentPane().add(ipThree);
  jFrame.getContentPane().add(ipFour);*/
  jFrame.getContentPane().add(byteText);
  jFrame.getContentPane().add(limitPing);
  jFrame.getContentPane().add(timeOut);
  jFrame.getContentPane().add(timeOutCount);
  jFrame.getContentPane().add(timerLabel);
  jFrame.getContentPane().add(pingTotal);
  jFrame.setJMenuBar(menuBar);
  
  menu.setMnemonic(79);
  menu.getAccessibleContext().setAccessibleDescription("Opciones");
  menuBar.add(menu);
  
  lastPings.setHighlighter(null);
  lastPings.setEditable(false);
  lastPings.setFocusable(false);
  lastPings.setCursor(null);
  lastPings.setOpaque(true);
  lastPings.setParagraphAttributes(attribs, true);
  
  lastPingsScroll.setHorizontalScrollBarPolicy(31);
  lastPingsScroll.setVerticalScrollBarPolicy(21);
  lastPingsScroll.setWheelScrollingEnabled(false);
  lastPingsScroll.setFocusable(false);
  lastPingsScroll.setEnabled(false);
  lastPingsScroll.setCursor(null);
  lastPingsScroll.setOpaque(false);
  lastPingsScroll.setViewportBorder(null);
  lastPingsScroll.setBorder(null);
  
  ovOpacity.addChangeListener(new ChangeListener()
  {
    public void stateChanged(ChangeEvent e)
    {
      prefs.putInt("extendedpingOverlayOpacity", ovOpacity.getValue());
      ov.updateVars(ovOpacity.getValue());
    }
  });
  httpCb.setMnemonic(79);
  httpCb.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      if (httpCb.isSelected())
      {
        println("http true");
        http = true;
        httpThr = new Thread(h);
        httpThr.start();
      }
      else
      {
        println("http false");
        http = false;
        h.close();
      }
    }
  });
  ovCb.setMnemonic(79);
  ovCb.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      if (ovCb.isSelected())
      {
        prefs.putBoolean("extendedpingOverlay", true);
        ovOpacity.setEnabled(true);
        ov.setVis(true);
        println("on");
      }
      else
      {
        prefs.putBoolean("extendedpingOverlay", false);
        ovOpacity.setEnabled(false);
        ov.setVis(false);
        println("off");
      }
    }
  });
  cbMenuItem.setMnemonic(49);
  cbMenuItem.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      if (cbMenuItem.getState())
      {
        cb.setState(true);
        trayDialogBool = true;
      }
      else
      {
        prefs.put("extendedpingOnclose", "none");
        cb.setState(false);
        trayDialogBool = false;
        cbMenuItem.setEnabled(false);
      }
    }
  });
  menu.add(cbMenuItem);
  
  muteCbItem.setMnemonic(50);
  muteCbItem.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      if (muteCbItem.getState())
      {
        prefs.putBoolean("extendedpingMute", true);
        if (timeOutMute != null) {
          timeOutMute.setValue(true);
        }
        if (minPingMute != null) {
          minPingMute.setValue(true);
        }
        println("muted");
      }
      else
      {
        prefs.putBoolean("extendedpingMute", false);
        if (timeOutMute != null) {
          timeOutMute.setValue(false);
        }
        if (minPingMute != null) {
          minPingMute.setValue(false);
        }
        println("unmuted");
      }
    }
  });
  menu.add(muteCbItem);
  
  versionsMenuItem.setMnemonic(51);
  versionsMenuItem.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      checkNotes(1);
    }
  });
  menu.add(versionsMenuItem);
  
  exitMenuItem.setMnemonic(52);
  exitMenuItem.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      println(trayDialogBool);
      try
      {
        Runtime.getRuntime().exec("taskkill /F /IM PING.EXE");
      }
      catch (Exception localException) {}
      System.exit(0);
    }
  });
  menu.add(exitMenuItem);
  
  ovPopUp.add(ovLimitPingCb);
  ovPopUp.add(ovDisable);
  ovPopUp.add(ovExitMenuItem);
  
  ovDisable.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      ovCb.setSelected(false);
      prefs.putBoolean("extendedpingOverlay", false);
      ovOpacity.setEnabled(false);
      ov.setVis(false);
    }
  });
  ovDisable.addMouseListener(new MouseAdapter()
  {
    public void mouseEntered(MouseEvent me)
    {
      mouseInside = true;
    }
    
    public void mouseExited(MouseEvent me)
    {
      mouseInside = false;
    }
  });
  ovExitMenuItem.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      println(trayDialogBool);
      try
      {
        Runtime.getRuntime().exec("taskkill /F /IM PING.EXE");
      }
      catch (Exception localException) {}
      System.exit(0);
    }
  });
  ovExitMenuItem.addMouseListener(new MouseAdapter()
  {
    public void mouseEntered(MouseEvent me)
    {
      mouseInside = true;
    }
    
    public void mouseExited(MouseEvent me)
    {
      mouseInside = false;
    }
  });
  ovLimitPingCb.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent e)
    {
      if (ovLimitPingCb.getState())
      {
        ovLimitPingCb.setState(true);
        prefs.putBoolean("extendedpingOverlaylimitping", true);
        println("limited");
      }
      else
      {
        ovLimitPingCb.setState(false);
        prefs.putBoolean("extendedpingOverlaylimitping", false);
        println("unlimited");
      }
    }
  });
  ovLimitPingCb.addMouseListener(new MouseAdapter()
  {
    public void mouseEntered(MouseEvent me)
    {
      mouseInside = true;
    }
    
    public void mouseExited(MouseEvent me)
    {
      mouseInside = false;
    }
  });
  ovPopUp.addMouseListener(new MouseAdapter()
  {
    public void mouseEntered(MouseEvent me)
    {
      mouseInside = true;
    }
    
    public void mouseExited(MouseEvent me)
    {
      mouseInside = false;
    }
  });
  ipLabel.setBounds(794, 5, 50, 20);
  byteLabel.setBounds(782, 65, 60, 20);
  
  numLineLabel.setBounds(723, 200, 100, 20);
  
  timeOutLabel.setBounds(708, 125, 192, 20);
  timerLabel.setBounds(708, 460, 192, 20);
  timerLabel.setFont(new Font("Serif", 0, 12));
  pingMath.setBounds(708, 475, 192, 20);
  pingMath.setFont(new Font("Serif", 0, 10));
  pingTotal.setBounds(708, 488, 192, 20);
  pingTotal.setFont(new Font("Serif", 0, 12));
  timeOutCount.setBounds(708, 502, 192, 20);
  timeOutCount.setFont(new Font("Serif", 0, 12));
  
  ipOne.setHorizontalAlignment(0);
  ipOne.setBounds(733, 30, 135, 20);
  ipOne.setText("google.com");
  /*ipTwo.setHorizontalAlignment(0);
  ipTwo.setBounds(754, 30, 43, 20);
  ipTwo.setText("168");
  ipThree.setHorizontalAlignment(0);
  ipThree.setBounds(800, 30, 43, 20);
  ipThree.setText("1");
  ipFour.setHorizontalAlignment(0);
  ipFour.setBounds(846, 30, 43, 20);
  ipFour.setText("1");*/
  
  byteText.setHorizontalAlignment(0);
  byteText.setBounds(774, 90, 50, 20);
  byteText.setText("1452");
  
  timeOut.setHorizontalAlignment(0);
  timeOut.setBounds(774, 150, 50, 20);
  timeOut.setText(prefs.get("extendedpingTimeout", timeOutDefault));
  
  limitPing.setHorizontalAlignment(0);
  limitPing.setBounds(706, 360, 186, 20);
  limitPing.setEnabled(false);
  
  textArea.setEditable(false);
  
  execBtn.setBounds(706, 524, 186, 40);
  
  minBtn.setBounds(706, 380, 186, 40);
  minBtn.setFont(new Font("Serif", 0, 10));
  
  logBtn.setBounds(706, 420, 186, 40);
  logBtn.setFont(new Font("Serif", 0, 10));
  logBtn.setToolTipText("Shift click para guardado rapido (al escritorio)");
  
  opacityLabel.setBounds(818, 200, 100, 20);
  ovOpacity.setOrientation(0);
  ovOpacity.setBounds(795, 220, 100, 16);
  
  httpCb.setBounds(740, 250, 125, 16);
  ovCb.setBounds(764, 180, 70, 16);
  scroll.setBounds(5, 5, 700, 560);
  jFrame.pack();
  jFrame.setDefaultCloseOperation(0);
  jFrame.addWindowListener(exitListener);
  jFrame.setVisible(true);
  
  execBtn.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent event)
    {
      if (!exec)
      {
        textArea.setText("");
        /*if (((ipOne.getText().matches("[0-9]*") ? 0 : 1) | (ipTwo.getText().matches("[0-9]*") ? 0 : 1) | (ipThree.getText().matches("[0-9]*") ? 0 : 1) | (ipFour.getText().matches("[0-9]*") ? 0 : 1)) != 0)
        {
          textArea.append(" [ERROR] Uno o mas segmentos de la IP introducida no sigue las reglas de IPv4 (solo numeros entre 0 y 255)\n");
          if (!ipOne.getText().matches("[0-9]*")) {
            ipOne.setText("");
          }
          if (!ipTwo.getText().matches("[0-9]*")) {
            ipTwo.setText("");
          }
          if (!ipThree.getText().matches("[0-9]*")) {
            ipThree.setText("");
          }
          if (!ipFour.getText().matches("[0-9]*")) {
            ipFour.setText("");
          }
        }
        else if ((!ipOne.getText().isEmpty()) && (parseInt(ipOne.getText()) >= 0) && (parseInt(ipOne.getText()) <= 255) && 
          (!ipTwo.getText().isEmpty()) && (parseInt(ipTwo.getText()) >= 0) && (parseInt(ipTwo.getText()) <= 255) && 
          (!ipThree.getText().isEmpty()) && (parseInt(ipThree.getText()) >= 0) && (parseInt(ipThree.getText()) <= 255) && 
          (!ipFour.getText().isEmpty()) && (parseInt(ipFour.getText()) >= 0) && (parseInt(ipFour.getText()) <= 255))
        {*/
        if (!byteText.getText().matches("[0-9]*"))
        {
          textArea.append(" [ERROR] Solo valores numéricos son validos (entre 0 y 65500)\n");
        }
        else if ((parseInt(byteText.getText()) < 0) || (parseInt(byteText.getText()) > 65500))
        {
          textArea.append(" [ERROR] El intervalo válido para los bytes es de 0 a 65500\n");
        }
        else
        {
          startTime = millis();
          
          textArea.append(new Date() + " [RUN] Se ha ejecutado el proceso de ping.\n");
          h.send(LocalTime.now() + " | Se ha ejecutado el proceso de ping.<br>", 4);
          ayy = new Thread(new pingClass());
          ayy.start();
          execBtn.setText("Parar");
          ipOne.setEditable(false);
          //ipTwo.setEditable(false);
          //ipThree.setEditable(false);
          //ipFour.setEditable(false);
          byteText.setEditable(false);
          timeOut.setEditable(false);
          
          lastPings.setText("\n");
          
          exec = (!exec);
        }
      }
      else
      {
        try
        {
          Runtime.getRuntime().exec("taskkill /F /IM PING.EXE");
          ayy.interrupt();
          ayy.join();
          textArea.append(new Date() + " [STOP] Se ha parado el proceso de ping.\n");
          h.send(LocalTime.now() + " | Se ha parado el proceso de ping.<br>", 4);
          ipOne.setEditable(true);
          //ipTwo.setEditable(true);
          //ipThree.setEditable(true);
          //ipFour.setEditable(true);
          byteText.setEditable(true);
          timeOut.setEditable(true);
          
          exec = (!exec);
        }
        catch (Exception localException) {}
        execBtn.setText("Ejecutar");
      }
    }
  });
  
  minBtn.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent event)
    {
      if (!limiter)
      {
        minPing = 0;
        limitPing.setText("1000");
        limitPing.setEnabled(true);
        minBtn.setText("Establecer minimo");
      }
      else
      {
        minPing = parseInt(limitPing.getText());
        limitPing.setEnabled(false);
        minBtn.setText("Aviso de Ping (0 para desactivar)");
        ovLimitPingCb.setText("Mostrar solo pings > " + minPing);
      }
      lowMinPing = round(0.3333F * minPing);
      midMinPing = round(0.6666F * minPing);
      
      limiter = (!limiter);
    }
  });
  logBtn.addActionListener(new ActionListener()
  {
    public void actionPerformed(ActionEvent event)
    {
      if ((event.getModifiers() & 0x1) != 0) {
        saveLog(true);
      } else {
        saveLog(false);
      }
    }
  });
}

public void draw()
{
  currentTime = (millis() - startTime);
  if (!dlPending)
  {
    updateTimer = (millis() - updateStartTime);
    if (updateTimer > 600000)
    {
      updateStartTime = millis();
      tryUpdate();
      println("trying update");
      updateTimer = 0;
    }
  }
  if (exec) {
    timerLabel.setText("Tiempo: " + (str(currentTime / 1000 / 60 / 60 % 24).length() != 1 ? str(currentTime / 1000 / 60 / 60 % 24) : new StringBuilder("0").append(str(currentTime / 1000 / 60 / 60 % 24)).toString()) + ":" + (
      str(currentTime / 1000 / 60 % 60).length() != 1 ? str(currentTime / 1000 / 60 % 60) : new StringBuilder("0").append(str(currentTime / 1000 / 60 % 60)).toString()) + ":" + (
      str(currentTime / 1000 % 60).length() != 1 ? str(currentTime / 1000 % 60) : new StringBuilder("0").append(str(currentTime / 1000 % 60)).toString()));
  }
}

WindowListener exitListener = new WindowAdapter()
{
  public void windowClosing(WindowEvent e)
  {
    if (!trayDialogBool)
    {
      trayDialogBool = true;
      confirm.setLayout(null);
      confirm.setSize(410, 100);
      confirm.setResizable(false);
      confirm.addWindowListener(new WindowAdapter()
      {
        public void windowClosing(WindowEvent e)
        {
          trayDialogBool = false;
        }
      });
      JLabel msg = new JLabel("Quieres cerrar el programa, o minimizarlo a la bandeja del sistema?");
      msg.setBounds(8, 10, 410, 20);
      
      cb.setLabel("No volver a preguntar");
      cb.setBounds(3, 40, 135, 20);
      
      JButton close = new JButton("Cerrar");
      close.setBounds(150, 40, 80, 20);
      close.addActionListener(new ActionListener()
      {
        public void actionPerformed(ActionEvent e)
        {
          if (cb.getState())
          {
            cbMenuItem.setEnabled(true);cbMenuItem.setState(true);prefs.put("extendedpingOnclose", "close");
          }
          else
          {
            trayDialogBool = false;
          }
          println(trayDialogBool);
          try
          {
            Runtime.getRuntime().exec("taskkill /F /IM PING.EXE");
          }
          catch (Exception localException) {}
          System.exit(0);
        }
      });
      JButton minimize = new JButton("Minimizar");
      minimize.setBounds(310, 40, 90, 20);
      minimize.addActionListener(new ActionListener()
      {
        public void actionPerformed(ActionEvent e)
        {
          if (cb.getState())
          {
            cbMenuItem.setEnabled(true);cbMenuItem.setState(true);prefs.put("extendedpingOnclose", "minimize");
          }
          else
          {
            trayDialogBool = false;
          }
          println(trayDialogBool);
          confirm.dispose();
          jFrame.setVisible(false);
        }
      });
      confirm.getContentPane().add(close);
      confirm.getContentPane().add(minimize);
      confirm.getContentPane().add(msg);
      confirm.getContentPane().add(cb);
      
      confirm.setLocationRelativeTo(null);
      
      confirm.setVisible(true);
    }
    else if ((trayDialogBool) && (!confirm.isVisible()))
    {
      if (prefs.get("extendedpingOnclose", onCloseDefault).equals("close"))
      {
        try
        {
          Runtime.getRuntime().exec("taskkill /F /IM PING.EXE");
        }
        catch (Exception localException) {}
        System.exit(0);
      }
      if (prefs.get("extendedpingOnclose", onCloseDefault).equals("minimize")) {
        jFrame.setVisible(false);
      }
    }
  }
};

public void popupTimer()
{
  int starttime = millis();
  int time = 0;
  println(mouseInside);
  while (time < 5000) {
    if (ovPopUp.isVisible())
    {
      println(Boolean.valueOf(mouseInside), Integer.valueOf(time));
      if (!mouseInside)
      {
        time = millis() - starttime;
      }
      else
      {
        starttime = millis();
        time = 0;
      }
    }
  }
  ovPopUp.setVisible(false);
}

public void saveLog(boolean fastSave)
{
  String sb = textArea.getText();
  if (!fastSave)
  {
    JFileChooser chooser = new JFileChooser();
    chooser.setSelectedFile(new File(System.getProperty("user.home") + "/Desktop/ping(" + day() + "-" + month() + "-" + year() + "_" + hour() + ":" + minute() + ":" + second() + ").log"));
    int retrival = chooser.showSaveDialog(null);
    if (retrival == 0) {
      try
      {
        FileWriter fw = new FileWriter(chooser.getSelectedFile());
        fw.write(sb.toString() + "\n" + timerLabel.getText() + "\n" + pingMath.getText() + "\n" + pingTotal.getText() + "\n" + timeOutCount.getText());
        fw.flush();
        fw.close();
      }
      catch (Exception ex)
      {
        ex.printStackTrace();
        JOptionPane.showMessageDialog(jFrame, ex, "Error", 0);
      }
    }
  }
  else
  {
    try
    {
      FileWriter fw = new FileWriter(System.getProperty("user.home") + "/Desktop/ping(" + day() + "-" + month() + "-" + year() + "_" + hour() + ":" + minute() + ":" + second() + ").log");
      fw.write(sb.toString() + "\n" + timerLabel.getText() + "\n" + pingMath.getText() + "\n" + pingTotal.getText() + "\n" + timeOutCount.getText());
      fw.flush();
      fw.close();
    }
    catch (Exception ex)
    {
      ex.printStackTrace();
      JOptionPane.showMessageDialog(jFrame, ex, "Error", 0);
    }
  }
}
