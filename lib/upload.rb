#include CloudinaryHelper

module Upload

    def self.upload_to_cloudinary(picture, public_id, tags)
        response = {}
        case picture
            when ActionDispatch::Http::UploadedFile # file upload via http
                response = Cloudinary::Uploader.upload(picture.open, :public_id => public_id, :tags => tags)

            when String # Base64
                response = Cloudinary::Uploader.upload(picture, :public_id => public_id, :tags => tags)

            else
                # TODO to be defined throws exception
        end
        response['url']
    end

    def self.get_url_image_from_cloudinary(file)
        uploads = Cloudinary::Uploader.upload(file.open)
        uploads['url']
    end

    def self.get_detail_image_from_cloudinary(file)
        Cloudinary::Uploader.upload(file.open)
    end

    def self.base64_to_cloudinary(file)
        uploads = Cloudinary::Uploader.upload(file)
        uploads['url']
    end

    def self.user_upload_to_cloudinary_with_params(picture, public_id, tags)
        response = {}
        case picture
            when ActionDispatch::Http::UploadedFile # file upload via http
                response = Cloudinary::Uploader.upload(picture.open, :public_id => public_id, :tags => tags)

            when String # Base64
                response = Cloudinary::Uploader.upload(picture, :public_id => public_id, :tags => tags)

            else
                # TODO to be defined throws exception
        end
        response['url']
    end

    def self.chat_upload_to_cloudinary_with_params(picture, tags)
        response = {}
        case picture
            when ActionDispatch::Http::UploadedFile # file upload via http
                response = Cloudinary::Uploader.upload(picture.open, :folder => "#{'dev/' if Rails.env.development?}chat_images", :tags => tags)

            when String # Base64
                response = Cloudinary::Uploader.upload(picture, :folder => "#{'dev/' if Rails.env.development?}chat_images", :tags => tags)

            else
                # TODO to be defined throws exception
        end
        response['url']
    end

    def self.magazine_upload_to_cloudinary_with_params(picture, public_id, tags)
        case picture
            when ActionDispatch::Http::UploadedFile # file upload via http
                Cloudinary::Uploader.upload(picture.open, :public_id => public_id, :tags => tags)
            when String # Base64
                Cloudinary::Uploader.upload(picture, :public_id => public_id, :tags => tags)
            else
                # TODO to be defined throws exception
        end
    end

    def self.delete_image_by_public_id(public_id)
        Cloudinary::Api.delete_resources([public_id]);
    end
end