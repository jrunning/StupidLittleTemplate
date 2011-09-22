require File.dirname(__FILE__) + '/teststrap'
include StupidLittleTemplate

context "A basic template proc" do
  helper(:tmpl) { ':foo :@bar :@@baz :Qux :$quux' }
  setup do
    foo   = 'FOO'
    @bar  = 'BAR'
    @@baz = 'BAZ'
    Qux   = 'QUX'
    $quux = 'QUUX'

    sltmpl tmpl, binding
  end

  asserts_topic.kind_of Proc
  asserts_topic.yields 'FOO BAR BAZ QUX QUUX'
end

context "A template with lots of noise" do
  helper(:tmpl) { <<-TMPL
                    <!DOCTYPE html>
                    <h1>:foo</h1>
                    <p>My :@bar is <a href=":@@baz">:Qux:$quux</a>!</p>
                  TMPL
  }

  setup do
    foo   = 'FOO'
    @bar  = 'BAR'
    @@baz = 'BAZ'
    Qux   = 'QUX'
    $quux = 'QUUX'

    sltmpl(tmpl, binding).yield
  end

  asserts_topic.kind_of String
  asserts_topic.includes  { '<h1>FOO</h1>'    }
  asserts_topic.includes  { 'My BAR is'       }
  asserts_topic.includes  { '<a href="BAZ">'  }
  asserts_topic.includes  { '">QUXQUUX</a>'   }
  denies_topic.includes   { ':' }
end

context "A template that has possible keys that aren't defined" do
  helper(:tmpl) { ':foo :xyzzy:bar :foo' }

  setup do
    foo = 'FOO'
    bar = 'BAR'

    sltmpl tmpl, binding
  end

  asserts_topic.yields 'FOO :xyzzyBAR FOO'

  context 'but are handled by method_missing' do
    helper(:method_missing) {|meth, *args, &block|
      meth == :xyzzy ? 'XYZZY' : super(meth, *args, block)
    }
    helper(:respond_to?) {|meth|
      meth == :xyzzy || super(meth)
    }
    setup {
      foo = 'FOO'; bar = 'BAR'
      topic
    }

    asserts_topic.yields 'FOO XYZZYBAR FOO'
  end
end

# How to handle this? Escape/stop character?
context "A template with keys adjacent to keylike characters" do
  helper(:tmpl) { ':widthx:height' }

  setup do
    width   = 800
    height  = 600

    sltmpl tmpl, binding
  end

  asserts_topic.yields { "800x600" }
end
