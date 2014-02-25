/*
 * Copyright 2010-2014, Sikuli.org, SikuliX.com
 * Released under the MIT License.
 *
 * modified RaiMan
 */
package org.sikuli.script;

/**
 * INTERNAL USE
 */
public interface EventSubject {

  public void addObserver(EventObserver o);

  public void notifyObserver();
}
