require "test_helper"

class PageTitleTest < ActiveSupport::TestCase

  EXCLUDED_TEMPLATES = %w(
    admin/preview/preview.html.erb
    layouts/admin.html.erb
    layouts/website.html.erb
  ).map do |f|
    File.expand_path(Rails.root + "app/views/" + f )
  end

  def test_every_page_sets_a_title
    Dir[Rails.root + "app/views/**/*.html.erb"].reject { |template|
      is_partial?(template) || is_excluded?(template)
    }.each do |template|
      assert_template_sets_page_title(template)
    end
  end

  private

  def is_partial?(template)
    File.basename(template) =~ /^_/
  end

  def is_excluded?(template)
    EXCLUDED_TEMPLATES.include?(template)
  end

  def assert_template_sets_page_title(template)
    assert_match /<% page_title /, File.read(template),
                 "could not locate setting of page title in #{template}"
  end
end