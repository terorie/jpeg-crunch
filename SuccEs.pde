public class SuccEs {
  
  public static final int INITIAL_SIZE = 32768;
  public static final float GROW_RATIO = 5/4;
  
  // Efficiency is a conspiracy!
  public byte[] array = new byte[INITIAL_SIZE];
  private int size = 0;

  public void _write(int b) {
    int pos = size;
    if (pos>=array.length)
      realloc(pos);
    size = pos+1;
    array[pos] = (byte)b;
  }
  
  public void realloc(int pos) {
    if(pos < size)
      return;
    byte[] newarray = new byte[(int)((pos+1)*GROW_RATIO)];
    System.arraycopy(array, 0, newarray, 0, size);
    array = newarray;
  }

  public void _write(byte[] b) {
    if(size+b.length >= array.length)
      realloc(size+b.length);
    
    System.arraycopy(b, 0, array, size, b.length);
    size += b.length;
  }
  
  public byte _read() {
    if(readPtr+1 >= size)
      return -1;
    return _read(readPtr++);
  }
  
  public byte _read(int pos) {
    if (pos>=size) throw new ArrayIndexOutOfBoundsException();
    return array[pos];
  }

  public int _read(byte[] b) {
    if(readPtr+1 >= size)
      return -1;
    
    int len = b.length;
    int end = readPtr+len;
    if (end+1 >= size) {
      end = size-1;
      len = end-readPtr;
    }
    
    System.arraycopy(array, readPtr, b, 0, len);
    readPtr = end;

    return len;
  }
  
  public int _read(byte[] b, int off, int len) {
    if(readPtr+1 >= size)
      return -1;
    
    int end = readPtr+len;
    if (end+1 >= size) {
      end = size-1;
      len = end-readPtr;
    }
    
    System.arraycopy(array, readPtr, b, off, len);
    readPtr = end;
    
    return len;
  }

  public void reset() {
    size = 0;
    readPtr = 0;
  }
  
  private int readPtr;
  
  private final OutputStream _o = new OutputStream() {
    public void write(int b) { _write(b); }
    public void write(byte[] b) { _write(b); }
  };
  
  private final InputStream _i = new InputStream() {
    public int read() { return (int)_read(); }
    public int read(byte[] b) { return _read(b); }
    public int read(byte[] b, int o, int l) { return _read(b, o, l); }
  };
  
  public OutputStream getOStream() {
    reset();
    return  _o;
  }
  
  public InputStream getIStream() {
    readPtr = 0;
    return _i;
  }
  
  public byte[] getArray() {
    byte buf[] = new byte[size];
    System.arraycopy(array, 0, buf, 0, size);
    return buf;
  }

}