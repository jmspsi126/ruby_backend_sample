class ParamData

  attr_accessor :customer_id, :locomotive_id

  def initialize(customer_id, locomotive_id)
   @customer_id = customer_id
   @locomotive_id = locomotive_id
  end

  def search_for(resources, criteria={}, inclusions=nil)

    if resources == Health
      criteria[:qes_sequence.in] = [0,1]
    end

    if criteria[:from]
      date = DateTime.parse(criteria.delete(:from))
      criteria[:time_utc.gte] = date
    end

    if criteria[:to]
      criteria[:to] == ''
      criteria[:to] == Date.today.to_s || criteria[:to] == (Date.today-1).to_s ? dateadd = 2 : dateadd = 1
      if criteria[:to] != ''
        date = DateTime.parse(criteria.delete(:to))
      else
        date = DateTime.parse(Date.today)
      end
      criteria[:time_utc.lte] = date+dateadd
    end

    if inclusions
      inclusions = inclusions.inject({}) { |e, x| e[x] = 0 }
      resources.where(customer_id: customer_id,locomotive_id: locomotive_id).only(inclusions)
    else
      resources.where(customer_id: customer_id,locomotive_id: locomotive_id)
    end.tap do |query|
      query.merge!(resources.where(criteria).limit(100)) unless criteria.empty?
    end.order_by(:time_utc.asc)
  end
end

