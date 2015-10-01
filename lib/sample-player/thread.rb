module SamplePlayer

  module Thread

    extend self

    def new(options = {}, &block)
      thread = ::Thread.new do
        begin
          if options[:timeout] === false
            yield
          else
            duration = options[:timeout] || 1
            Timeout::timeout(duration) { yield }
          end
        rescue Timeout::Error
          ::Thread.current.kill
        rescue Exception => exception
          ::Thread.main.raise(exception)
        end
      end
      thread.abort_on_exception = true
      thread
    end

  end

end
