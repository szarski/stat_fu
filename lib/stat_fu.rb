Hash.class_eval do
  def each_combination(&block)
    blocks = [block]
    self.to_a.select {|k,v| v.is_a?(Array)}.each_with_index do |(param_name, values), block_index|
      blocks << lambda do |params|
        values.each do |value|
          blocks[block_index].call(params.merge({param_name => value}))
        end
      end
    end
    blocks.last.call(self.reject {|k,v| v.is_a?(Array)})
  end
end
