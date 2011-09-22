module StupidLittleTemplate
  # http://stackoverflow.com/questions/3648551/regex-that-matches-valid-ruby-local-variable-names/3648591#3648591
  SLTParamExp = /(:((?:\$|@{1,2})?[A-Za-z_][A-Za-z0-0]*))/

  def sltmpl template, bndng
    tmpl_params = template.scan(SLTParamExp)

    proc {
      tmpl_params.reduce(template.clone) do |str, param|
        test = "defined?(#{param[1]}) or respond_to?(:'#{param[1].to_sym}')"

        eval(test, bndng) ? 
          str.gsub(param[0], eval(param[1], bndng).to_s) : str
      end
    }
  end
end
