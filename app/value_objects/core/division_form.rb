
class Core::DivisionForm
    include ActiveModel::Model

    attr_accessor(:id, :name, :rule, :division_page, :is_deleted) # ["name:String: self.name:String", "rule:String: self.rule:String", "division_page:String: self.division_page:String", "is_deleted:Boolean: self.is_deleted:Boolean"])

    # Validations
    
    validates :rule, presence: true    
    validates :division_page, presence: true    
    

    def save
        if valid?
            division = Core::Division.new(name: self.name, rule: self.rule, division_page: self.division_page, is_deleted: self.is_deleted)
            division.save
            true
        else
            false
        end
    end

    def update        
        if valid?
            division = Core::Division.find(self.id)
            division.update_attributes!(name: self.name, rule: self.rule, division_page: self.division_page, is_deleted: self.is_deleted)
            true
        else
            false
        end
    end
end
