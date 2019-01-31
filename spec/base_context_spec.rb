require 'context-pattern'

class TestContext < Context::BaseContext
  view_helpers :method1,
               :method2

  attr_accessor :foo

  def method1
    'method1'
  end

  def method2
    'method2'
  end

  def method3
    'method3'
  end

  protected

  attr_accessor :bar1

  def protected_method
    'protected_method'
  end

  private

  def private_method
    'private_method'
  end
end

class TestContext2 < Context::BaseContext
  attr_accessor :blah
end

class TestContext3 < Context::BaseContext
end

describe Context::BaseContext do
  describe '.new' do
    it 'accepts attributes when there are associated public setter methods' do
      context = TestContext.new(foo: 1)
      expect(context.foo).to eq(1)
    end

    it 'raises an ArgumentError if the setter is protected' do
      method = :bar1
      expect(TestContext.instance_methods.include?(method)).to eq(true)
      expect { TestContext.new(method => 1) }
        .to raise_error(ArgumentError, "unknown attribute: #{method}")
    end

    it 'raises an ArgumentError if the setter is private' do
      method = :bar2
      expect(TestContext.new.instance_eval("#{method} = 1")).to eq(1)
      expect { TestContext.new(method => 1) }
        .to raise_error(ArgumentError, "unknown attribute: #{method}")
    end
  end

  describe '.has_view_helper?' do
    it 'is true for declared view helpers' do
      expect(TestContext.has_view_helper?(:method1)).to eq(true)
      expect(TestContext.has_view_helper?('method2')).to eq(true)
    end

    it 'is false for public methods that are not declared as view helpers' do
      method = :method3
      expect(TestContext.public_instance_methods.include?(method)).to eq(true)
      expect(TestContext.has_view_helper?(method)).to eq(false)
    end
  end

  describe '.wrap' do
    it 'returns a new instance with the `parent_context` attribute set to '\
    'the supplied context' do
      contextA = TestContext.new
      contextB = TestContext2.wrap(contextA)

      expect(contextB.class).to eq(TestContext2)
      expect(contextB.class.superclass).to eq(Context::BaseContext)
      expect(contextB.parent_context).to eq(contextA)
    end

    it 'allows setting attributes when wrapping a context' do
      contextA = TestContext.new
      contextB = TestContext2.wrap(contextA, blah: 1)

      expect(contextB.blah).to eq(1)
    end

    it 'allows accessing attributes of parent contexts after wrapping' do
      contextA = TestContext.new(foo: 1)
      contextB = TestContext2.wrap(contextA)

      expect(contextB.foo).to eq(1)
    end

    it 'allows setting attributes of parent contexts when wrapping a context' do
      contextA = TestContext.new
      contextB = TestContext2.wrap(contextA, foo: 1)

      expect(contextA.foo).to eq(1)
      expect(contextB.foo).to eq(1)
    end
  end

  describe '#context_class_chain' do
    let(:instance) { TestContext.new(foo: 1) }
    let(:instance2) { TestContext2.wrap(instance) }
    let(:instance3) { TestContext3.wrap(instance2) }

    it 'returns an array of all chained context class names in the order '\
    'they were wrapped' do
      expect(instance.context_class_chain).to eq(['TestContext'])
      expect(instance2.context_class_chain)
        .to eq(['TestContext', 'TestContext2'])
      expect(instance3.context_class_chain)
        .to eq(['TestContext', 'TestContext2', 'TestContext3'])
    end
  end

  describe '#has_view_helper?' do
    let(:instance) { TestContext.new(foo: 1) }
    let(:instance2) { TestContext2.wrap(instance) }
    let(:instance3) { TestContext3.wrap(instance2) }

    it 'is true for a declared view helper' do
      expect(instance.has_view_helper?(:method1)).to eq(true)
      expect(instance.has_view_helper?('method2')).to eq(true)
    end

    it 'is false for public methods not declared as view helpers' do
      expect(instance.method3).to eq('method3')
      expect(instance.has_view_helper?(:method3)).to eq(false)
    end

    it 'is true if a wrapped context has a certain declared view helper' do
      expect(instance2.has_view_helper?(:method1)).to eq(true)
      expect(instance2.has_view_helper?('method2')).to eq(true)
    end

    it 'is true if a grand-wrapped context has a declared view helper' do
      expect(instance3.has_view_helper?(:method1)).to eq(true)
      expect(instance3.has_view_helper?('method2')).to eq(true)
    end
  end

  describe 'method_missing' do
    let(:instance) { TestContext.new(foo: 1) }
    let(:instance2) { TestContext2.wrap(instance) }
    let(:instance3) { TestContext3.wrap(instance2) }

    it 'responds to public methods from a wrapped context' do
      expect(instance2.method3).to eq('method3')
    end

    it 'response to public methods from a grand-wrapped context' do
      expect(instance3.method3).to eq('method3')
    end

    it 'does not respond to protected methods from a wrapped context' do
      expect(instance.instance_eval('protected_method'))
        .to eq('protected_method')

      expect { instance2.instance_eval('protected_method') }
        .to raise_error(NoMethodError)
      expect { instance2.protected_method }.to raise_error(NoMethodError)
    end

    it 'does not respond to private methods from a wrapped context' do
      expect(instance.instance_eval('private_method'))
        .to eq('private_method')

      expect { instance2.instance_eval('private_method') }
        .to raise_error(NoMethodError)
      expect { instance2.private_method }.to raise_error(NoMethodError)
    end
  end
end
