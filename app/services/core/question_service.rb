class Core::QuestionService
    def create_question(question_form)
        question_form.save
    end

    def update_question(question_form)
        question_form.update
    end

    def delete_question(id)
        question = find_question(id)
        return question.delete, Core::Question.page(1).total_pages
    end

    def find_question(id)
        Core::Question.find(id)
    end

    def find_questions(query)
        page = query.delete(:page).to_i                
        query[:is_deleted] = false
        res = Core::Question.where(query).order_by({:created_at => -1 })
        total_pages = ( res.count().to_f / Core::Question.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end
