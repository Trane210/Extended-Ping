boolean mouseInside = false;

public class Overlay extends JWindow {
  int X;
  int Y;
  JLabel noClick = new JLabel("");
  JPanel pinPanel = new JPanel();
  boolean pinDrag = false;
  boolean pinClick = false;
  int numOfLines = prefs.getInt("extendedpingOverlayNumoflines", ovNumLineDefault);
  int spacing = 17;
  int alpha = prefs.getInt("extendedpingOverlayOpacity", ovOpacityDefault);
  int posX;
  int posY;
  Color darkRed = new Color(128, 0, 0, alpha);
  Color red = new Color(255, 0, 0, alpha);
  Color darkGreen = new Color(0, 128, 0, alpha);
  Color green = new Color(0, 255, 0, alpha);
  
  public void updateVars(int a)
  {
    alpha = a;
    posX = parseInt(prefs.get("extendedpingOverlayPos", ovPosDefault).split(",")[0]);
    posY = parseInt(prefs.get("extendedpingOverlayPos", ovPosDefault).split(",")[1]);
    setLocation(posX, posY);
    darkRed = new Color(128, 0, 0, alpha);
    red = new Color(255, 0, 0, alpha);
    darkGreen = new Color(0, 128, 0, alpha);
    green = new Color(0, 255, 0, alpha);
    lastPings.setBackground(new Color(0, 0, 0, alpha));
    if (!pinClick) {
      pinPanel.setBackground(darkRed);
    } else {
      pinPanel.setBackground(darkGreen);
    }
    repaint();
  }
  
  Overlay()
  {
    Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    int maxLines = (int)screenSize.getHeight() / spacing;
    
    String[] numLineCount = new String[maxLines];
    for (int i = 0; i < (int)screenSize.getHeight() / 17; i++)
    {
      numLineCount[i] = str(i + 1);
      println(numLineCount[i]);
    }
    numLineCombo = new JComboBox(numLineCount);
    
    numLineCombo.setSelectedIndex(prefs.getInt("extendedpingOverlayNumoflines", ovNumLineDefault) - 1);
    numLineCombo.setBounds(732, 220, 50, 20);
    numLineCombo.addActionListener(new ActionListener()
    {
      public void actionPerformed(ActionEvent e)
      {
        String n = (String)((JComboBox)e.getSource()).getSelectedItem();
        numOfLines = parseInt(n);
        prefs.putInt("extendedpingOverlayNumoflines", parseInt(n));
        setSize(40, spacing * numOfLines + 10);
        lastPingsScroll.setBounds(0, 0, 40, spacing * numOfLines);
        noClick.setBounds(0, 0, 40, spacing * numOfLines);
        pinPanel.setBounds(0, spacing * numOfLines, 40, 10);
        Point p = getLocation();
        if (p.x < 0) {
          p.x = 0;
        }
        if (p.x + 40 > displayWidth) {
          p.x = (displayWidth - 40);
        }
        if (p.y < 0) {
          p.y = 0;
        }
        if (p.y + spacing * numOfLines + 10 > displayHeight) {
          p.y = (displayHeight - spacing * numOfLines - 10);
        }
        setLocation(p.x, p.y);
        prefs.put("extendedpingOverlayPos", str(p.x) + "," + str(p.y));
      }
    });
    jFrame.getContentPane().add(numLineCombo);
    
    println("creating overlay");
    
    setLayout(null);
    setBounds(posX, posY, 40, spacing * numOfLines + 10);
    setBackground(new Color(0, 0, 0, 1));
    lastPingsScroll.setBounds(0, 0, 40, spacing * numOfLines);
    lastPings.setForeground(new Color(255, 255, 255, alpha));
    lastPings.setBackground(new Color(0, 0, 0, alpha));
    noClick.setOpaque(true);
    noClick.setBackground(new Color(255, 0, 0, 0));
    noClick.setBounds(0, 0, 40, spacing * numOfLines);
    pinPanel.setOpaque(true);
    pinPanel.setBackground(darkRed);
    pinPanel.setBounds(0, spacing * numOfLines, 40, 10);
    System.setProperty("sun.java2d.noddraw", "true");
    AWTUtilities.setWindowOpaque(this, false);
    
    noClick.addMouseListener(new MouseAdapter()
    {
      public void mouseEntered(MouseEvent me)
      {
        mouseInside = true;
      }
      
      public void mouseExited(MouseEvent me)
      {
        mouseInside = false;
      }
      
      public void mousePressed(MouseEvent me)
      {
        if (me.getButton() == 1)
        {
          if (!pinClick)
          {
            X = me.getX();
            Y = me.getY();
          }
          if (me.getClickCount() >= 2)
          {
            jFrame.setVisible(true);
            jFrame.toFront();
          }
        }
      }
      
      public void mouseReleased(MouseEvent me)
      {
        if (me.getButton() == 1)
        {
          if (!pinClick)
          {
            Point p = getLocation();
            if (p.x < 0) {
              p.x = 0;
            }
            if (p.x + 40 > displayWidth) {
              p.x = (displayWidth - 40);
            }
            if (p.y < 0) {
              p.y = 0;
            }
            if (p.y + spacing * numOfLines + 10 > displayHeight) {
              p.y = (displayHeight - spacing * numOfLines - 10);
            }
            setLocation(p.x, p.y);
            prefs.put("extendedpingOverlayPos", str(p.x) + "," + str(p.y));
          }
        }
        else if (me.getButton() == 3)
        {
          ovPopUp.show(noClick, noClick.getMousePosition().x, noClick.getMousePosition().y);
          thread("popupTimer");
        }
      }
    });
    noClick.addMouseMotionListener(new MouseMotionAdapter()
    {
      public void mouseDragged(MouseEvent me)
      {
        if ((SwingUtilities.isLeftMouseButton(me)) && 
          (!pinClick))
        {
          Point p = getLocation();
          setLocation(p.x + (me.getX() - X), p.y + (me.getY() - Y));
        }
      }
    });
    pinPanel.addMouseListener(new MouseAdapter()
    {
      public void mousePressed(MouseEvent me)
      {
        if (me.getButton() == 1)
        {
          if (!pinClick)
          {
            X = me.getX();
            Y = me.getY();
            pinPanel.setBackground(red);
          }
          else
          {
            X = me.getX();
            Y = me.getY();
            pinPanel.setBackground(green);
          }
          repaint();
        }
      }
      
      public void mouseReleased(MouseEvent me)
      {
        if (me.getButton() == 1)
        {
          if (pinDrag)
          {
            if (!pinClick)
            {
              Point p = getLocation();
              if (p.x < 0) {
                p.x = 0;
              }
              if (p.x + 40 > displayWidth) {
                p.x = (displayWidth - 40);
              }
              if (p.y < 0) {
                p.y = 0;
              }
              if (p.y + spacing * numOfLines + 10 > displayHeight) {
                p.y = (displayHeight - spacing * numOfLines - 10);
              }
              setLocation(p.x, p.y);
              prefs.put("extendedpingOverlayPos", str(p.x) + "," + str(p.y));
              pinPanel.setBackground(darkRed);
              pinDrag = false;
            }
            else
            {
              pinPanel.setBackground(darkGreen);
              pinDrag = false;
            }
          }
          else if (!pinClick)
          {
            pinPanel.setBackground(darkGreen);
            pinClick = (!pinClick);
          }
          else
          {
            pinPanel.setBackground(darkRed);
            pinClick = (!pinClick);
          }
          repaint();
        }
      }
    });
    pinPanel.addMouseMotionListener(new MouseMotionAdapter()
    {
      public void mouseDragged(MouseEvent me)
      {
        if (SwingUtilities.isLeftMouseButton(me)) {
          if (!pinClick)
          {
            Point p = getLocation();
            setLocation(p.x + (me.getX() - X), p.y + (me.getY() - Y));
            pinDrag = true;
          }
          else
          {
            pinDrag = true;
          }
        }
      }
    });
    add(pinPanel);
    add(noClick);
    add(lastPingsScroll);
    
    setAlwaysOnTop(true);
    repaint();
    
    println("overlay created");
  }
  
  private void setVis(boolean vis)
  {
    if (vis) {
      setVisible(true);
    } else {
      setVisible(false);
    }
  }
}
