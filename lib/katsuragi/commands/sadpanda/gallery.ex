defmodule Katsuragi.Commands.Sadpanda.Gallery do
  @moduledoc """
  Wrapper over an ExHentai gallery.
  """

  defstruct [
    :archiver_key,
    :category,
    :expunged,
    :file_count,
    :file_size,
    :id,
    :token,
    :grouped_tags,
    :japanese_title,
    :posted,
    :rating,
    :tags,
    :original_tags,
    :thumbnail,
    :title,
    :torrent_count,
    :uploader
  ]
end
