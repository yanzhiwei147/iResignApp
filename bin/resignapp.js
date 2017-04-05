#!/usr/bin/env node
'use strict';

const packageJson = require('../package.json');
const colors = require('colors');
const SignApp = require('../lib/tools.js');
const conf = require('minimist')(process.argv.slice(2), {
  boolean: [
    '7', 'use-7zip',
    'r', 'replace',
    'L', 'identities',
    'v', 'verify-twice',
    'E', 'entry-entitlement',
    'f', 'without-fairplay',
    'p', 'parallel',
    'w', 'without-watchapp',
    'u', 'unfair',
    'M', 'massage-entitlements',
    'f', 'force-family',
    's', 'single',
    'S', 'self-signed-provision',
    'c', 'clone-entitlements',
    'u', 'unsigned-provision',
    'V', 'dont-verify',
    'B', 'bundleid-access-group'
  ]
});

const options = {
  file: conf._[0] || 'undefined',
  outfile: conf.output || conf.o,
  bundleid: conf.bundleid || conf.b,
  identity: conf.identity || conf.i,
  mobileprovision: conf.mobileprovision || conf.m,
  keychain: conf.keychain || conf.k
};

colors.setTheme({
  error: 'red',
  warn: 'green',
  msg: 'yellow'
});

const ca = new SignApp(options);

if (conf.identities || conf.L) {
  ca.getIdentities((err, ids) => {
    if (err) {
      console.error(colors.error(err));
    } else {
      ids.forEach((id) => {
        console.log(id.hash, id.name);
      });
    }
  });
} else if (conf.version) {
  console.log(packageJson.version);
} else if (conf.h || conf.help || conf._.length === 0) {
  const cmd = process.argv[1].split('/').pop();
  console.error(
`Usage:

  ${cmd} [--options ...] [input-ipafile]

  -b, --bundleid [BUNDLEID]                   Change the bundleid when repackaging
  -i, --identity [iPhone Distribution:xxx]    Specify hash-id of the identity to use
  -k, --keychain [KEYCHAIN]                   Specify alternative keychain file
  -m, --mobileprovision [FILE]                Specify the mobileprovision file to use
  -o, --output [APP.IPA]                      Path to the output IPA filename  
      --version                               Show SignApp version
  [input-ipafile]                             Path to the IPA file to resign

Example:

  ${cmd} -i "iPhone Distribution:xxx" -b "com.xx.test" -k ~/Library/Keychains/login.keychain test-app.ipa
`);
} else {
  console.log(colors.msg("Begin resign..."));
  ca.resign();
  console.log(colors.msg("Finish resign..."));
}
