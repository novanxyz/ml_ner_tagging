require 'dry-container'
require 'dry-auto_inject'
require 'markazuna/cache'

module Markazuna
    class DIContainer
        extend Dry::Container::Mixin

		register 'statistic_service' do
			Admin::StatisticService.new
		end

		register 'magazine_service' do
			Admin::MagazineService.new
		end

		register 'question_service' do
			Core::QuestionService.new
		end

		register 'contact_time_service' do
			Insurances::Contact_timeService.new
		end

		register 'faq_service' do
			Insurances::FaqService.new
		end

		register 'provider_service' do
			Insurances::ProviderService.new
		end

		register 'template_service' do
			Insurances::TemplateService.new
		end

		register 'insurance_service' do
			Insurances::InsuranceService.new
		end

		register 'division_action_service' do
			Core::Division_actionService.new
		end

		register 'role_service' do
			Core::RoleService.new
		end

		register 'automated_notification_service' do
			Admin::AutomatedNotificationService.new
		end
		
		register 'notification_service' do
			Users::NotificationService.new
		end

		register 'interest_service' do
			Core::InterestService.new
		end

		register 'user_meta_description_service' do
			Core::UserMetaDescriptionService.new
		end

		register 'doctor_service' do
			Core::DoctorService.new
		end

		register 'division_service' do
			Core::DivisionService.new
		end

		register 'user_service' do
			Core::UserService.new
		end

		register 'claim_service' do
			Insurances::ClaimService.new
		end

		register 'admin_service' do
			Core::AdminService.new
		end

		register 'quota_service' do
			Insurances::QuotaService.new
		end

		register 'city_service' do
			Admin::CityService.new
		end

        register 'article_service' do
			Core::ArticleService.new
		end

        register 'group_service' do
            Admin::GroupService.new
        end

        register 'system_cache' do
            Markazuna::Cache.instance # return singleton object
        end
    end

    # dependency injection
    INJECT = Dry::AutoInject(Markazuna::DIContainer)
end