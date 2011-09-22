module StupidLittleTemplate
  # http://stackoverflow.com/questions/3648551/regex-that-matches-valid-ruby-local-variable-names/3648591#3648591
  SLTParamExp = /(:((?:\$|@{1,2})?[A-Za-z_][A-Za-z0-0]*))/

  def sltmpl template, bndng
    tmpl_params = template.scan(SLTParamExp)

    proc {
      out_str = template.clone

      tmpl_params.reduce(out_str) do |str, param|
        if eval "defined? #{param[1]}", bndng
          str.gsub(param[0],
            eval(param[1], bndng).to_s
          )
        else str end
      end
    }
  end
end
