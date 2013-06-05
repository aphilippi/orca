require 'net/ssh'
require 'net/sftp'

class Hull::Node
  attr_reader :name, :host

  def self.find(name)
    @nodes[name]
  end

  def self.register(node)
    @nodes ||= {}
    @nodes[node.name] = node
  end

  def initialize(name, host)
    @name = name
    @host = host
    @connection = nil
    Hull::Node.register(self)
  end

  def upload(from, to)
    log('sftp', "UPLOAD: #{from} => #{to}")
    sftp.upload!(from, to)
  end

  def download(from, to)
    log('sftp', "DOWLOAD: #{from} => #{to}")
    sftp.download!(from, to)
  end

  def sftp
    @sftp ||= Net::SFTP::Session.new(connection)
  end

  def execute(cmd)
    log('execute', cmd.cyan)
    output = ""
    connection.exec! cmd do |channel, stream, data|
      output += data if stream == :stdout
      data.split("\n").each do |line|
        msg = stream == :stdout ? line.green : line.red
        log(stream, msg)
      end
    end
    output
  end

  def log(context, msg)
    puts "#{@host} [#{context.to_s.bold}] #{msg}"
  end

  def connection
    return @connection if @connection
    @connetion = Net::SSH.start(@host, 'root')
  end
end


class Hull::MockNode
  def execute(cmd)
    log('execute', cmd)
  end
end