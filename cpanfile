requires "Cpanel::JSON::XS" => "0";
requires "DateTime::Format::RFC3339" => "0";
requires "Exporter" => "0";
requires "HTTP::Request" => "0";
requires "LWP::UserAgent" => "0";
requires "Moo" => "0";
requires "Moo::Role" => "0";
requires "Params::CheckCompiler" => "0";
requires "Scalar::Util" => "0";
requires "Sub::Quote" => "0";
requires "Type::Library" => "0";
requires "Type::Utils" => "0";
requires "Types::Common::Numeric" => "0";
requires "Types::Common::String" => "0";
requires "Types::Standard" => "0";
requires "Types::URI" => "0";
requires "URI" => "0";
requires "namespace::autoclean" => "0";
requires "perl" => "5.006";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "HTTP::Response" => "0";
  requires "Path::Tiny" => "0";
  requires "Test2::Bundle::Extended" => "0";
  requires "Test2::Plugin::NoWarnings" => "0";
  requires "Test::LWP::UserAgent" => "0";
  requires "Test::More" => "0.96";
  requires "URI::Escape" => "0";
  requires "lib" => "0";
  requires "perl" => "5.006";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "perl" => "5.006";
};

on 'develop' => sub {
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Perl::Critic" => "1.123";
  requires "Perl::Tidy" => "20140711";
  requires "Test::CPAN::Changes" => "0.19";
  requires "Test::Code::TidyAll" => "0.24";
  requires "Test::EOL" => "0";
  requires "Test::More" => "0.88";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Spelling" => "0.12";
  requires "Test::Synopsis" => "0";
  requires "Test::Version" => "1";
};
