# Active Storage has no built-in validations, so attachments are checked here.
# The content type is the one Active Storage detects with Marcel: from the file's
# signature when the format has one (PDF, PNG, JPG), and from the name otherwise.
module AttachmentValidation
  extend ActiveSupport::Concern

  TYPE_NAMES = { "application/pdf" => "PDF", "image/jpeg" => "JPG", "image/png" => "PNG" }.freeze

  class_methods do
    def validates_attachment(name, content_types:, max_size:)
      validate do
        file = public_send(name)
        next unless file.attached?

        unless file.content_type.in?(content_types)
          allowed = content_types.map { |type| TYPE_NAMES.fetch(type, type) }
          errors.add(name, "debe ser #{allowed.to_sentence(two_words_connector: " o ", last_word_connector: " o ")}")
        end

        if file.byte_size > max_size
          errors.add(name, "no puede pesar más de #{ActiveSupport::NumberHelper.number_to_human_size(max_size)}")
        end
      end
    end
  end
end
