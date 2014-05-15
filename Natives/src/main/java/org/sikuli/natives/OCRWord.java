/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 2.0.12
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package org.sikuli.natives;

public class OCRWord extends OCRRect {
  private long swigCPtr;

  protected OCRWord(long cPtr, boolean cMemoryOwn) {
    super(VisionProxyJNI.OCRWord_SWIGUpcast(cPtr), cMemoryOwn);
    swigCPtr = cPtr;
  }

  protected static long getCPtr(OCRWord obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        VisionProxyJNI.delete_OCRWord(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public void setScore(float value) {
    VisionProxyJNI.OCRWord_score_set(swigCPtr, this, value);
  }

  public float getScore() {
    return VisionProxyJNI.OCRWord_score_get(swigCPtr, this);
  }

  public String getString() {
    return VisionProxyJNI.OCRWord_getString(swigCPtr, this);
  }

  public OCRChars getChars() {
    return new OCRChars(VisionProxyJNI.OCRWord_getChars(swigCPtr, this), true);
  }

  public OCRWord() {
    this(VisionProxyJNI.new_OCRWord(), true);
  }

}
