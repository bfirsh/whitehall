class Admin::AttachmentsController < Admin::BaseController
  before_filter :limit_attachable_access, if: :attachable_is_an_edition?
  before_filter :check_attachable_allows_html_attachments, if: :html?

  def index; end

  def order
    attachment_ids = params[:ordering].sort_by { |_, ordering| ordering.to_i }.map { |id, _| id }
    attachable.reorder_attachments(attachment_ids)

    redirect_to attachable_attachments_path(attachable), notice: 'Attachments re-ordered'
  end

  def new; end

  def create
    if attachment.save
      redirect_to attachable_attachments_path(attachable), notice: "Attachment '#{attachment.title}' uploaded"
    else
      render :new
    end
  end

  def update
    if attachment.update_attributes(attachment_params)
      message = "Attachment '#{attachment.title}' updated"
      redirect_to attachable_attachments_path(attachable), notice: message
    else
      render :edit
    end
  end

  def destroy
    attachment.destroy
    redirect_to attachable_attachments_path(attachable), notice: 'Attachment deleted'
  end

  def attachable_attachments_path(attachable)
    case attachable
    when Response
      [:admin, attachable.consultation, attachable.singular_routing_symbol]
    else
      [:admin, typecast_for_attachable_routing(attachable), Attachment]
    end
  end
  helper_method :attachable_attachments_path

private
  def attachment
    @attachment ||= find_attachment || build_attachment
  end
  helper_method :attachment

  def find_attachment
    attachable.attachments.find(params[:id]) if params[:id]
  end

  def build_attachment
    html? ? build_html_attachment : build_file_attachment
  end

  def build_html_attachment
    attributes = params.fetch(:attachment, {}).merge(attachable: attachable)
    HtmlAttachment.new(attributes)
  end

  def build_file_attachment
    attributes = params.fetch(:attachment, {}).merge(attachable: attachable)
    attributes.reverse_merge!(attachment_data: AttachmentData.new)
    FileAttachment.new(attributes)
  end

  def attachment_params
    data_attributes = params[:attachment][:attachment_data_attributes]
    if data_attributes && data_attributes[:file]
      params[:attachment]
    else
      params[:attachment].except(:attachment_data_attributes)
    end
  end

  def html?
    params[:html] == 'true'
  end

  def check_attachable_allows_html_attachments
    redirect_to attachable_attachments_path(attachable) unless attachable.allows_html_attachments?
  end

  def attachable_param
    params.keys.find { |k| k =~ /_id$/ }
  end

  def attachable_class
    if attachable_param
      attachable_param.sub(/_id$/, '').classify.constantize
    else
      raise ActiveRecord::RecordNotFound
    end
  rescue NameError
    raise ActiveRecord::RecordNotFound
  end

  def attachable_id
    params[attachable_param]
  end

  def attachable
    @attachable ||= attachable_class.find(attachable_id)
  end
  helper_method :attachable

  def attachable_is_an_edition?
    attachable_class == Edition
  end

  def limit_attachable_access
    enforce_permission!(:see, attachable)
    enforce_permission!(:update, attachable)

    @edition = attachable
    prevent_modification_of_unmodifiable_edition
  end
end
