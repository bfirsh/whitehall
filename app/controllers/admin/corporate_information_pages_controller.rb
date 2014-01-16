class Admin::CorporateInformationPagesController < Admin::BaseController
  before_filter :find_organisation
  before_filter :build_corporate_information_page, only: [:new, :create]
  before_filter :find_corporate_information_page, only: [:edit, :update, :destroy]

  def index
    @corporate_information_pages = @organisation.corporate_information_pages
  end

  def new
    build_corporate_information_page
  end

  def create
    build_corporate_information_page
    if @corporate_information_page.save
      redirect_to [:admin, @organisation], notice: "#{@corporate_information_page.title} created successfully"
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def edit
  end

  def update
    if @corporate_information_page.update_attributes(corporate_information_page_params)
      redirect_to [:admin, @organisation], notice: "#{@corporate_information_page.title} updated successfully"
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = <<-EOF
      This page has been saved since you opened it. Your version appears
      at the top and the latest version appears at the bottom. Please
      incorporate any relevant changes into your version and then save it.
    EOF
    @conflicting_corporate_information_page = @organisation.corporate_information_pages.find(params[:id])
    @corporate_information_page.lock_version = @conflicting_corporate_information_page.lock_version
    render action: "edit"
  end

  def destroy
    if @corporate_information_page.destroy
      redirect_to [:admin, @organisation], notice: "#{@corporate_information_page.title} deleted successfully"
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

private

  def find_corporate_information_page
    @corporate_information_page = @organisation.corporate_information_pages.find(params[:id])
  end

  def build_corporate_information_page
    @corporate_information_page ||= @organisation.corporate_information_pages.build(corporate_information_page_params)
  end

  def find_organisation
    @organisation =
      if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      elsif params.has_key?(:worldwide_organisation_id)
        WorldwideOrganisation.find(params[:worldwide_organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def corporate_information_page_params
    params.fetch(:corporate_information_page, {})
          .permit(:body, :type_id, :summary, :lock_version)
  end
end
