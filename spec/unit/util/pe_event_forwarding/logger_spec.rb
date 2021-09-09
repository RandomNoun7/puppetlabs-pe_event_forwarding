require 'spec_helper'
require_relative '../../../../files/util/logger'

describe PeEventForwarding::Logger do
  subject(:io_logger) { described_class.new(io, 'NONE') }

  let(:io) { StringIO.new }
  let(:json_io) { JSON.parse(io.string) }
  let(:settings_hash) { default_settings_hash }

  context '.info' do
    let(:settings_hash) { super().merge('log_level' => 'INFO') }

    it 'has correct default source' do
      io_logger.info('blah')
      expect(json_io['source']).to eql('pe_event_forwarding')
    end

    it 'has correct custom source' do
      io_logger.info('test msg', source: 'test_src')
      expect(json_io['source']).to eql('test_src')
    end

    it 'has correct message' do
      io_logger.info('test msg')
      expect(json_io['message']).to eql('test msg')
    end

    it 'has correct exit_code' do
      io_logger.info('test msg', exit_code: 2)
      expect(json_io['exit_code']).to be(2)
    end

    it 'has correct severity (INFO)' do
      io_logger.info('test msg')
      expect(json_io['severity']).to eql('INFO')
    end

    it 'log level set to INFO; gets correct numerical translation' do
      io_logger.level = PeEventForwarding::Logger::LOG_LEVELS[settings_hash['log_level']]
      expect(io_logger.level).to eq(1)
    end
  end

  context '.fatal' do
    let(:settings_hash) { super().merge('log_level' => 'FATAL') }

    it 'has correct default source' do
      io_logger.fatal('blah')
      expect(json_io['source']).to eql('pe_event_forwarding')
    end

    it 'has correct custom source' do
      io_logger.fatal('test msg', source: 'test_src')
      expect(json_io['source']).to eql('test_src')
    end

    it 'has correct message' do
      io_logger.fatal('test msg')
      expect(json_io['message']).to eql('test msg')
    end

    it 'has correct exit_code' do
      io_logger.fatal('test msg', exit_code: 2)
      expect(json_io['exit_code']).to be(2)
    end

    it 'has correct severity (FATAL)' do
      io_logger.fatal('fatal message')
      expect(json_io['severity']).to eql('FATAL')
    end

    it 'log level set to FATAL; gets correct numerical translation' do
      io_logger.level = PeEventForwarding::Logger::LOG_LEVELS[settings_hash['log_level']]
      expect(io_logger.level).to eq(4)
    end
  end

  context '.warn' do
    let(:settings_hash) { super().merge('log_level' => 'WARN') }

    it 'has correct default source' do
      io_logger.warn('blah')
      expect(json_io['source']).to eql('pe_event_forwarding')
    end

    it 'has correct custom source' do
      io_logger.warn('test msg', source: 'test_src')
      expect(json_io['source']).to eql('test_src')
    end

    it 'has correct message' do
      io_logger.warn('test msg')
      expect(json_io['message']).to eql('test msg')
    end

    it 'has correct exit_code' do
      io_logger.warn('test msg', exit_code: 2)
      expect(json_io['exit_code']).to be(2)
    end

    it 'has correct severity (WARN)' do
      io_logger.warn('fatal message')
      expect(json_io['severity']).to eql('WARN')
    end

    it 'log level set to WARN; gets correct numerical translation' do
      io_logger.level = PeEventForwarding::Logger::LOG_LEVELS[settings_hash['log_level']]
      expect(io_logger.level).to eq(2)
    end
  end
end
