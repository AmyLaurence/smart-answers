class NodePresenter
  extend Forwardable
  delegate [:outcome?] => :@node

  def initialize(node, state = nil, _options = {}, _params = {})
    @node = node
    @state = state || SmartAnswer::State.new(nil)
  end
end
