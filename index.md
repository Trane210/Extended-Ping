## Que haces aqui?

Bueno, pondré algo de codigo aquí... supongo...

```java
boolean loop = false;

  void setup() {
    background(255);
    size(800,800);
  }

  void draw() {
    if(!loop) background(0);
    else background(255);
    loop=!loop;
  }
```

