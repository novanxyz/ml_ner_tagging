# README
# Backoffice migration to rails 5 and polymer 3

The architecture are using rails only to generate polymer element then let polymer element do data interaction using REST API

Things that already done:

* Main menu
* Modify template to do View=>Edit mode changes.
* Generate from template for under Users Main Menu, for *LIST* only, need to work at form view gain.
* Dashbaord view



Things that need to be done:

* Continue to fix the logic of forms under menu Users.
* Work on logic on the backend
* Activate third-parties libs
* Need to Select calendar view webcomponents 
the closest is this : https://vaadin.com/directory/component/haithemmosbahischeduler-component, but still in polymer 2.
* etc...
* adding new models to the menu :

  `rails generate markazuna <Scope>/<ModelName> --fields=<FieldName>:<FieldType`
  
  contoh:
  
 `rails generate markazuna Admin/Statistic --fields=name:String label:String value:Float delta:Float stat_time:DateTime`

it will generate:

  * model-file ( may need to match the tables/collection names,
    ** Inherited Class cannot be differ from Core Module, since _type field on the collection tables store the class name
    **
  * controller-file, may add additional query-params that may used
  * service-file, need to define query clause from search/query params
  * value-object-file, need to define data-only validations
  * views file ( rendered view routing happens at backoffice#page, may need to combine multiple views/component base )
  * adding route ( please match the route generated and menu )

Thing that found while researching:

* cloudinary not support rails 5.
https://github.com/cloudinary/cloudinary_gem/issues/211#issuecomment-236515162


