class AttributeHander < YARD::Handlers::Ruby::Legacy::Base
  handles /\Aattribute\b/
  namespace_only

  def process
    name = statement.tokens[2].text.gsub(':','')
    object = YARD::CodeObjects::MethodObject.new(namespace, name)
    register(object)
    object.dynamic = true
  end

end
