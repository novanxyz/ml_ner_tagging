module MetaDescriptionHelper
    def format_meta_description_value(question_meta_description)
        case question_meta_description.meta_description.sequence
            when 1
                if question_meta_description.meta_description_value.value.downcase == 'ya'
                    'Pertanyaan untuk pengguna'
                else
                    'Pertanyaan untuk orang lain'
                end

            when 2
                "Age: #{question_meta_description.text_value} - Sex: #{question_meta_description.meta_description_value.value}"

            when 3
                if question_meta_description.meta_description_value.value.downcase == 'ya'
                    "Penyakit kronis: #{question_meta_description.text_value}"
                else
                    'Tidak ada penyakit'
                end

            when 4
                if question_meta_description.meta_description_value.value.downcase == 'ya'
                    "Alergi obat: #{question_meta_description.text_value}"
                else
                    'Tidak ada alergi obat'
                end

            when 5
                if question_meta_description.meta_description_value.value.downcase == 'ya'
                    "Alergi lain: #{question_meta_description.text_value}"
                else
                    'Tidak ada alergi yang lain'
                end

            else
                # TODO please add handler here
        end
    end
end