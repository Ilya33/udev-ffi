requires 'perl', '5.008001';

requires 'FFI::Platypus';
requires 'FFI::CheckLib';
requires 'IPC::Cmd';

requires 'PkgConfig', '0.17026';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
