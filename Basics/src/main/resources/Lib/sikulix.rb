# coding: utf-8
# SikuliX for Ruby

require 'java'

# Classes and methods for using SikuliX
module SikuliX4Ruby
  java_import org.sikuli.basics.SikuliX
  java_import org.sikuli.script.Screen
  java_import org.sikuli.script.Region
  java_import org.sikuli.script.ScreenUnion

  java_import org.sikuli.script.Observing
  java_import org.sikuli.script.ObserverCallBack

  java_import org.sikuli.script.Constants
  java_import org.sikuli.script.Finder

  java_import org.sikuli.script.Button
  java_import org.sikuli.basics.OS

  java_import org.sikuli.script.Match
  java_import org.sikuli.script.Pattern
  java_import org.sikuli.script.Location

  java_import org.sikuli.script.ImagePath

  java_import org.sikuli.script.App
  java_import org.sikuli.script.Key
  java_import org.sikuli.script.KeyModifier
  java_import org.sikuli.script.Mouse

  java_import org.sikuli.basics.Settings
  java_import org.sikuli.basics.ExtensionManager

  java_import org.sikuli.script.compare.DistanceComparator
  java_import org.sikuli.script.compare.VerticalComparator
  java_import org.sikuli.script.compare.HorizontalComparator

  java_import org.sikuli.basics.SikuliScript

  java_import org.sikuli.basics.Debug

  #
  # This method generates a wrapper for Java Native exception processing
  # in native java methods. It allows to detect a line number in script
  # that opened in IDE where the exception was appearing.
  #
  # obj - class for the wrapping
  # methods_array - array of method names as Symbols
  def self.native_exception_protect(obj, methods_array)
    methods_array.each do |name|
      m = obj.instance_method name
      obj.class_exec do
        alias_method(('java_' + name.to_s).to_sym, name)
        define_method(name) do |*args|
          begin
            # java specific call for unbound methods
            m.bind(self).call(*args)
          rescue NativeException => e
            raise StandardError, e.message
          end
        end
      end
    end
  end

  # Redefinition of native org.sikuli.script.Region class
  class Region
    # Service class for all callbacks processing
    class RObserverCallBack < ObserverCallBack # :nodoc: all
      def initialize(block)
        super()
        @block = block
      end
      %w(appeared vanished changed).each do |name|
        define_method(name) do |*args|
          @block.call(*(args.first @block.arity))
        end
      end
    end
    alias_method :java_onAppear, :onAppear
    alias_method :java_onVanish, :onVanish
    alias_method :java_onChange, :onChange

    # Redefinition of the java method for Ruby specific
    def onAppear(target, &block)
      java_onAppear target, RObserverCallBack.new(block)
    end

    # Redefinition of the java method for Ruby specific
    def onVanish(target, &block)
      java_onVanish target, RObserverCallBack.new(block)
    end

    # Redefinition of the java method for Ruby specific
    def onChange(&block)
      java_onChange RObserverCallBack.new(block)
    end

    # alias_method :java_findAll,  :findAll
    # def findAll(*args)
    #   begin
    #     java_findAll(*args)
    #   rescue NativeException => e; raise e.message; end
    # end
  end

  # Wrap following java-methods by an exception processor
  native_exception_protect(
    Region,
    [:find, :findAll, :wait, :waitVanish, :exists,
     :click, :doubleClick, :rightClick, :hover, :dragDrop,
     :type, :paste, :observe]
   )

  # Default screen object for "undotted" methods.
  $SIKULI_SCREEN = Screen.new

# This is an alternative for method generation using define_method
#  # Generate hash of ('method name'=>method)
#  # for all possible "undotted" methods.
#  UNDOTTED_METHODS =
#    [$SIKULI_SCREEN, SikuliX].reduce({}) do |h, obj|
#      h.merge!(
#        obj.methods.reduce({}) do |h2, name|
#          h2.merge!(name => obj.method(name))
#        end
#      )
#    end

  # It makes possible to use java-constants as a methods
  # Example: Key.CTRL instead of Key::CTRL
  [Key, KeyModifier].each do |obj|
    obj.class_exec do
      def self.method_missing(name)
        if (val = const_get(name))
          return val
        end
        fails "method missing #{name}"
      end
    end
  end

  # Generate static methods in SikuliX4Ruby context
  # for possible "undotted" methods.
  [$SIKULI_SCREEN, SikuliX].each do |obj|
    mtype = (obj.class == Class ? :java_class_methods : :java_instance_methods)
    obj.java_class.method(mtype).call.map(&:name).uniq.each do |name|
      obj_meth = obj.method(name)
      define_singleton_method(name) do |*args, &block|
        obj_meth.call(*args, &block)
      end
      define_method(name) { |*args, &block| obj_meth.call(*args, &block) }
    end
  end

  # Display some help in interactive mode.
  def shelp
    SikuliScript.shelp
  end

  # TODO: check it after Env Java-class refactoring
  java_import org.sikuli.script.Env
  java_import org.sikuli.basics.HotkeyListener

  class Env  # :nodoc: all
    class RHotkeyListener < HotkeyListener
      def initialize(block)
        super()
        @block = block
      end

      def hotkeyPressed(event)
        @block.call event
      end
    end
  end

  ##
  # Register hotkeys
  #
  # Example:
  #    addHotkey( Key::F1, KeyModifier::ALT + KeyModifier::CTRL ) do
  #      popup 'hallo', 'Title'
  #    end
  #
  def addHotkey(key, modifiers, &block)
    Env.addHotkey key, modifiers, Env::RHotkeyListener.new(block)
  end

  ##
  # Unregister hotkeys
  #
  # Example:
  #    removeHotkey( Key::F1, KeyModifier::ALT + KeyModifier::CTRL )
  def removeHotkey(key, modifiers)
    Env.removeHotkey key, modifiers
  end

  # Generate methods like constructors.
  # Example: Pattern("123.png").similar(0.5)
  [Pattern, Region, Screen, App].each do |cl|
    name = cl.java_class.simple_name
    define_singleton_method(name) { |*args| cl.new(*args) }
    define_method(name) { |*args| cl.new(*args) }
  end
end

# This is an alternative for method generation using define_method
## This method allow to call "undotted" methods that belong to
## Region/Screen or SikuliX classes.
# def self.method_missing(name, *args, &block)
#
#  if (method = SikuliX4Ruby::UNDOTTED_METHODS[name])
#    begin
#      ret = method.call(*args, &block)
#      # Dynamic methods that throw a native Java-exception,
#      # hide a line number in the scriptfile!
#      # Object.send(:define_method, name){ |*args| method.call(*args) }
#      return ret
#    rescue NativeException => e
#      raise StandardError, "SikuliX4Ruby: Problem (#{e})\n" \
#        "with undotted method: #{name} (#{args})"
#    end
#  else
#    fail "undotted method '#{name}' missing"
#  end
# end
