class Bidu::House::ReportBuilder
  def build(key, parameters = {})
    params = parameters.slice(:period, :threshold)
    config = configs[key].merge(params)
    Bidu::House::ErrorReport.new(config)
  end

  def add_config(key, config)
    configs[key] = config
  end

  private

  def configs
    @configs ||= {}
  end
end
