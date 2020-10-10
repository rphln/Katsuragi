defmodule Katsuragi.Commands.Whale do
  @moduledoc """
  A whale.
  """

  use Percussion, :command

  def aliases do
    ["whale"]
  end

  def describe do
    @moduledoc
  end

  def call(_request) do
    """
    :dollar::dollar::dollar::dollar:         :dollar::dollar::dollar:
      :dollar::dollar::dollar:   :dollar::dollar::dollar:
         :dollar::dollar::dollar::dollar::dollar:
             :dollar::dollar:
             :dollar::dollar:
             :dollar::dollar:                   :whale::whale:       :whale::whale:
               :dollar:                       :whale::whale::whale::whale:
            :whale::whale::whale::whale::whale:                  :whale::whale:
        :whale::whale::whale::whale::whale::whale::whale:                :whale::whale:
     :whale::whale::whale::whale::whale::whale::whale::whale::whale:             :whale::whale:
    :whale::whale::whale::white_circle::black_circle::whale::whale::whale::whale::whale::whale::whale:      :whale::whale:
    :whale::whale::whale::black_circle::black_circle::whale::whale::whale::whale::whale::whale::whale::whale:   :whale::whale:
    :whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale:
    :whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale:
    :whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale::whale:
       :whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2:
          :whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2::whale2:
    """
  end
end
