## Que haces aqui?

Bueno,

```markdown
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

