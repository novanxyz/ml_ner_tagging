module Markazuna
    module CommonModel
        DEFAULT_PAGE_SIZE = 25
        def as_json(options={})
            json = super(:except => :_id)
            json.merge('id' => self.id.to_s)
        end
    end
end