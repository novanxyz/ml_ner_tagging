# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('vendor')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w( tinymce/tinymce.min
                                                  tinymce/skins/lightgray/skin.min
                                                  admin/bootstrap/dist/css/bootstrap.min.css
                                                  admin/font-awesome/css/font-awesome.min.css
                                                  admin/nprogress/nprogress.css
                                                  admin/iCheck/skins/flat/green.css
                                                  admin/bootstrap-progressbar/css/bootstrap-progressbar-3.3.4.min.css
                                                  admin/jqvmap/dist/jqvmap.min.css
                                                  admin/bootstrap-daterangepicker/daterangepicker.css
                                                  admin/animate.css/animate.min.css
                                                  admin/jquery/dist/jquery.min.js
                                                  admin/bootstrap/dist/js/bootstrap.min.js
                                                  admin/fastclick/lib/fastclick.js
                                                  admin/nprogress/nprogress.js
                                                  admin/Chart.js/dist/Chart.min.js
                                                  admin/gauge.js/dist/gauge.min.js
                                                  admin/bootstrap-progressbar/bootstrap-progressbar.min
                                                  admin/iCheck/icheck.min.js
                                                  admin/skycons/skycons.js
                                                  admin/Flot/jquery.flot.js
                                                  admin/Flot/jquery.flot.pie.js
                                                  admin/Flot/jquery.flot.time.js
                                                  admin/Flot/jquery.flot.stack.js
                                                  admin/Flot/jquery.flot.resize.js
                                                  admin/flot.orderbars/js/jquery.flot.orderBars.js
                                                  admin/flot-spline/js/jquery.flot.spline.min.js
                                                  admin/flot.curvedlines/curvedLines.js
                                                  admin/DateJS/build/date.js
                                                  admin/jqvmap/dist/jquery.vmap.js
                                                  admin/jqvmap/dist/maps/jquery.vmap.world.js
                                                  admin/jqvmap/examples/js/jquery.vmap.sampledata.js
                                                  admin/moment/min/moment.min.js
                                                  admin/bootstrap-daterangepicker/daterangepicker.js
                                                  admin/custom.css
                                                  admin/custom.js
                                                  front/jquery.min.js
                                                  front/bootstrap.min.js
                                                  front/main.js
                                                  front/bootstrap.min.css
                                                  front/font-awesome.min.css
                                                  front/style.css
                                                  fonts/* )
