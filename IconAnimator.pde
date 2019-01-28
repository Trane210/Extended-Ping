public class IconAnimator extends Thread
{
  JFrame frame = null;
  ArrayList<Image> images;
  long msBetweenImages;
  
  public IconAnimator(JFrame frame, ArrayList<Image> images, long msBetweenImages)
  {
    this.frame = frame;
    this.images = images;
    this.msBetweenImages = msBetweenImages;
  }
  
  public void run()
  {
    for (int i = 0; i < images.size(); i++)
    {
      try
      {
        if (i == 22) {
          i = 31;
        }
        if (i == 55) {
          i = 4;
        }
        if (((i >= 4) && (i <= 22)) || ((i >= 31) && (i <= 55))) {
          frame.setIconImage((Image)images.get(i));
        }
        Thread.sleep(msBetweenImages);
      }
      catch (Exception localException) {}
      if (frame == null) {
        return;
      }
    }
  }
}
