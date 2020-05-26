( function _Integration_test_s_() {

'use strict';

//

if( typeof module !== 'undefined' )
{

  let _ = require( 'wTools' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wAppBasic' );

}

//

let _ = _global_.wTools;
let fileProvider = _testerGlobal_.wTools.fileProvider;
let path = fileProvider.path;

// --
// test
// --

function sample( test )
{
  let context = this;
  let ready = new _.Consequence().take( null );
  
  let sampleDir = path.join( __dirname, '../../../../sample' );
  
  let appStartNonThrowing = _.process.starter
  ({  
    currentPath : sampleDir,
    outputCollecting : 1,
    outputGraying : 1,
    throwingExitCode : 0,
    ready : ready,
    mode : 'fork'
  })
  
  let found = fileProvider.filesFind
  ({
    filePath : path.join( sampleDir, '**/*.(s|js|ss)' ),
    withStem : 0,
    withDirs : 0,
    mode : 'distinct',
    mandatory : 0,
  });

  /* */

  let startTime;

  for( let i = 0 ; i < found.length ; i++ )
  {
    if( _.longHas( found[ i ].exts, 'browser' ) )
    continue;

    ready
    .then( () =>
    {
      test.case = found[ i ].relative;
      startTime = _.time.now();
      return null;
    })

    if( _.longHas( found[ i ].exts, 'throwing' ) )
    {
      appStartNonThrowing({ execPath : found[ i ].relative })
      .then( ( got ) =>
      {
        console.log( _.time.spent( startTime ) );
        test.description = 'nonzero exit code';
        test.notIdentical( got.exitCode, 0 );
        return null;
      })
    }
    else
    {
      appStartNonThrowing({ execPath : found[ i ].relative })
      .then( ( got ) =>
      {
        console.log( _.time.spent( startTime ) );
        test.description = 'good exit code';
        test.identical( got.exitCode, 0 );
        if( got.exitCode )
        return null;
        test.description = 'have no uncaught errors';
        test.identical( _.strCount( got.output, 'ncaught' ), 0 );
        test.identical( _.strCount( got.output, 'rror' ), 0 );
        test.description = 'have some output';
        test.ge( got.output.split( '\n' ).length, 2 )
        return null;
      })
    }
  }

  /* */

  return ready;
}

sample.timeOut = 60000;

//

function eslint( test )
{
  let rootPath = path.join( __dirname, '../../../..' );
  let eslint = path.join( rootPath, 'node_modules/.bin/eslint' );
  
  let ready = new _.Consequence().take( null );
  
  let start = _.process.starter
  ({ 
    execPath : eslint, 
    mode : 'fork', 
    currentPath : rootPath, 
    args : [ '-c', '.eslintrc.yml', '--ext', '.js,.s,.ss', '--ignore-pattern', '**/*.test/**' ],
    throwingExitCode : 0,
    ready
  })
  
  //
  
  ready.then( () => 
  {
    test.case = 'eslint proto';
    return null;
  })
  start( 'proto/**' )
  .then( ( got ) => 
  {
    test.identical( got.exitCode, 0 );
    return null;
  })
  
  //
  
  ready.then( () => 
  {
    test.case = 'eslint samples';
    return null;
  })
  start( 'sample/**' )
  .then( ( got ) => 
  {
    test.identical( got.exitCode, 0 );
    return null;
  })
  
  return ready;
}

eslint.timeOut = 120000;


// --
// declare
// --

var Self =
{

  name : 'Tools.Math.Integration',
  silencing : 1,
  enabled : 1,

  tests :
  {
    sample,
    eslint
  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_global_.wTester.test( Self.name );

})();

