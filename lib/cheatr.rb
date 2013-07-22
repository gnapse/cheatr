module Cheatr
  autoload :Client, 'cheatr/client'
  autoload :Server, 'cheatr/server'

  SHEET_NAME_REGEXP = /\A[a-z]+([\.\-\_][a-z]+)*\z/
end
