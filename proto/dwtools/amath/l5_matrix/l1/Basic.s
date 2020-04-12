(function _Basic_s_() {

'use strict';

/* zzz :

- implement power
- implement submatrix
-- make sure inputTransposing of product set correctly
- implement compose

*/

//

let _ = _global_.wTools;
let abs = Math.abs;
let min = Math.min;
let max = Math.max;
let longSlice = Array.prototype.slice;
let sqrt = Math.sqrt;
let sqr = _.math.sqr;

_.assert( _.objectIs( _.vectorAdapter ), 'wMatrix requires vector module' );
_.assert( !!_.all );

/**
 * @classdesc Multidimensional structure which in the most trivial case is Matrix of scalars. A matrix of specific form could also be classified as a vector. MathMatrix heavily relly on MathVector, which introduces VectorAdapter. VectorAdapter is a reference, it does not contain data but only refer on actual ( aka Long ) container of lined data.  Use MathMatrix for arithmetic operations with matrices, to triangulate, permutate or transform matrix, to get a specific or the general solution of a system of linear equations, to get LU, QR decomposition, for SVD or PCA. Also, Matrix is a convenient and efficient data container, you may use it to continuously store huge an array of arrays or for matrix computation.
 * @class wMatrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

let Parent = null;
let Self = function wMatrix( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

// --
// inter
// --

function init( o )
{
  let self = this;

  self._changing = [ 1 ];

  self[ stridesEffectiveSymbol ] = null;
  self[ lengthSymbol ] = null;
  self[ scalarsPerElementSymbol ] = null;
  self[ occupiedRangeSymbol ] = null;
  self[ breadthSymbol ] = null;

  self[ stridesSymbol ] = null;
  self[ offsetSymbol ] = null;

  _.workpiece.initFields( self );
  _.assert( arguments.length <= 1 );

  Object.preventExtensions( self );

  self.strides = null;
  self.offset = 0;
  self.breadth = null;

  self._changing[ 0 ] -= 1;

  if( o )
  {

    if( _.mapIs( o ) )
    {

      if( o.scalarsPerElement !== undefined )
      {
        _.assert( _.longIs( o.buffer ) );
        if( !o.offset )
        o.offset = 0;
        if( !o.dims )
        {
          if( o.strides )
          o.dims = [ o.scalarsPerElement, ( o.buffer.length - o.offset ) / o.strides[ 1 ] ];
          else
          o.dims = [ o.scalarsPerElement, ( o.buffer.length - o.offset ) / o.scalarsPerElement ];
          o.dims[ 1 ] = Math.floor( o.dims[ 1 ] );
        }
        _.assert( _.intIs( o.dims[ 1 ] ) );
        delete o.scalarsPerElement;
      }

    }

    self.copy( o );
  }
  else
  {
    self._sizeChanged();
  }

}

//

/**
 * Static routine Is() checks whether the provided argument is an instance of Matrix.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var got = _.Matrix.Is( matrix );
 * console.log( got );
 * // log : true
 *
 * @param { * } src - The source argument.
 * @returns { Boolean } - Returns whether the argument is instance of Matrix.
 * @throws { Error } If arguments.length is not equal to one.
 * @static
 * @function Is
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function Is( src )
{
  _.assert( arguments.length === 1, 'Expects single argument' );
  return _.matrixIs( src );
}

//

function _traverseAct( it )
{
  let self = this;

  if( it.resetting === undefined )
  it.resetting = 1;

  _.Copyable.prototype._traverseAct.pre.call( this, _traverseAct, [ it ] );

  if( !it.dst )
  {
    _.assert( it.technique === 'object' );
    _.assert( it.src instanceof Self );
    it.dst = it.src.clone();
    return it.dst;
  }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( it.resetting !== undefined );
  _.assert( !!it.dst );

  let dst = it.dst;
  let src = it.src;
  let srcIsInstance = src instanceof Self;
  let dstIsInstance = dst instanceof Self;

  if( src === dst )
  return dst;

  /* */

  if( _.longIs( src ) )
  {
    dst.copyFromBuffer( src );
    return dst;
  }
  else if( _.numberIs( src ) )
  {
    dst.copyFromScalar( src );
    return dst;
  }

  if( dstIsInstance )
  dst._changeBegin();

  if( src.dims )
  {
    _.assert( it.resetting || !dst.dims || _.longIdentical( dst.dims , src.dims ) );
  }

  if( dstIsInstance )
  if( dst._stridesEffective )
  dst[ stridesEffectiveSymbol ] = null;

  /* */

  if( dstIsInstance )
  if( src.buffer !== undefined )
  {
    /* use here resetting option maybe!!!? */

    dst.dims = null;

    if( srcIsInstance && dst.buffer && dst.scalarsPerMatrix === src.scalarsPerMatrix )
    {
    }
    else if( !srcIsInstance )
    {
      dst.buffer = src.buffer;
      if( src.breadth !== undefined )
      dst.breadth = src.breadth;
      if( src.offset !== undefined )
      dst.offset = src.offset;
      if( src.strides !== undefined )
      dst.strides = src.strides;
    }
    else if( src.buffer && !dst.buffer )
    {
      dst.buffer = self.long.longMakeUndefined( src.buffer , src.scalarsPerMatrix );
      dst.offset = 0;
      dst.strides = null;
      dst[ stridesEffectiveSymbol ] = dst.StridesForDimensions( src.dims, !!dst.inputTransposing );
    }
    else if( src.buffer && dst.scalarsPerMatrix !== src.scalarsPerMatrix )
    {
      dst.buffer = self.long.longMakeUndefined( src.buffer , src.scalarsPerMatrix );
      dst.offset = 0;
      dst.strides = null;
      dst[ stridesEffectiveSymbol ] = dst.StridesForDimensions( src.dims, !!dst.inputTransposing );
    }
    else debugger;

  }

  /* */

  if( src.dims )
  dst.dims = src.dims;

  it.copyingAggregates = 0;
  dst = _.Copyable.prototype._traverseAct( it );

  if( srcIsInstance )
  _.assert( _.longIdentical( dst.dims , src.dims ) );

  if( dstIsInstance )
  {
    dst._changeEnd();
    _.assert( dst._changing[ 0 ] === 0 );
  }

  if( srcIsInstance )
  {

    if( dstIsInstance )
    {
      _.assert( dst.hasShape( src ) );
      src.scalarEach( function( it )
      {
        dst.scalarSet( it.indexNd, it.scalar );
      });

    }
    else
    {
      let extract = it.src.extractNormalized();
      let newIteration = it.iterationNew();
      newIteration.select( 'buffer' );
      newIteration.src = extract.buffer;
      dst.buffer = _._cloneAct( newIteration );
      dst.offset = extract.offset;
      dst.strides = extract.strides;
    }
  }

  return dst;
}

_traverseAct.iterationDefaults = Object.create( _._cloner.iterationDefaults ); /* xxx */
_traverseAct.defaults = _.mapSupplementOwn( Object.create( _._cloner.defaults ), _traverseAct.iterationDefaults );

function _equalAre( it )
{

  _.assert( arguments.length === 1, 'Expects exactly three arguments' );
  _.assert( _.routineIs( it.onNumbersAreEqual ) );
  _.assert( _.lookIterationIs( it ) );

  it.continue = false;

  if( !( it.src2 instanceof Self ) )
  {
    it.result = false;
    debugger;
    return it.result;
  }

  if( it.src.length !== it.src2.length )
  {
    it.result = false;
    debugger;
    return it.result;
  }

  if( it.src.buffer.constructor !== it.src2.buffer.constructor )
  {
    it.result = false;
    return it.result;
  }

  if( !_.longIdentical( it.src.breadth, it.src2.breadth )  )
  {
    it.result = false;
    debugger;
    return it.result;
  }

  it.result = it.src.scalarWhile( function( atom, indexNd, indexFlat )
  {
    let atom2 = it.src2.scalarGet( indexNd );
    return it.onNumbersAreEqual( atom, atom2 );
  });

  _.assert( _.boolIs( it.result ) );
  return it.result;
}

_.routineExtend( _equalAre, _._equal );

//

function _longGet()
{
  let self = this;
  if( _.routineIs( self ) )
  self = self.prototype;
  let result = self.vectorAdapter.long;
  _.assert( _.objectIs( result ) );
  return result;
}

// --
// import / export
// --

function _copy( src, resetting )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  let it = _._cloner( self._traverseAct, { src, dst : self, /*resetting, */ technique : 'object' } );

  self._traverseAct( it );

  return it.dst;
}

//

/**
 * Method copy() copies scalars from buffer {-src-} into inner matrix.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 2, 2 ] );
 * console.log( matrix.toStr() );
 * // log : +0, +0,
 * //       +0, +0,
 * matrix.copy( [ 1, 2, 3, 4 ] );
 * console.log( matrix.toStr() );
 * // log : +1, +2,
 * //       +3, +4,
 *
 * @param { Long|Number } src - A Long or single scalar.
 * @returns { Matrix } - Returns original instance of Matrix filled by values from {-src-}.
 * @method copy
 * @throws { Error } If arguments.length is not equal to one.
 * @throws { Error } If {-src-} is not a Long, not a Number.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function copy( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  return self._copy( src, 0 );
}

//

// function copyResetting( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   return self._copy( src, 1 );
// }

//

/**
 * Method copyFromScalar() applies scalar {-src-} to each element of inner matrix.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 2, 2 ] );
 * console.log( matrix.toStr() );
 * // log : +0, +0,
 * //       +0, +0,
 * matrix.copyFromScalar( 5 );
 * console.log( matrix.toStr() );
 * // log : +5, +5,
 * //       +5, +5,
 *
 * @param { Number } src - Scalar to fill the matrix.
 * @returns { Matrix } - Returns original instance of Matrix filled by scalar values.
 * @method copyFromScalar
 * @throws { Error } If arguments.length is not equal to one.
 * @throws { Error } If {-src-} is not a Number.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function copyFromScalar( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.numberIs( src ) );

  self.scalarEach( ( it ) => self.scalarSet( it.indexNd, src ) );

  return self;
}

//

/**
 * Method copyFromBuffer() copies scalars from buffer {-src-} into inner matrix.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 2, 2 ] );
 * console.log( matrix.toStr() );
 * // log : +0, +0,
 * //       +0, +0,
 * matrix.copyFromBuffer( [ 1, 2, 3, 4 ] );
 * console.log( matrix.toStr() );
 * // log : +1, +2,
 * //       +3, +4,
 *
 * @param { Long } src - A Long for assigning to the matrix.
 * @returns { Matrix } - Returns original instance of Matrix filled by values from {-src-}.
 * @method copyFromBuffer
 * @throws { Error } If arguments.length is less then one.
 * @throws { Error } If {-src-} is not a Long.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function copyFromBuffer( src )
{
  let self = this;
  self._bufferAssign( src );
  return self;
}

//

/**
 * Method clone() makes copy of the matrix.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * console.log( matrix.toStr() );
 * // log : +1, +2,
 * //       +3, +4,
 * var copy = matrix.clone();
 * console.log( copy.toStr() );
 * // log : +1, +2,
 * //       +3, +4,
 * console.log( matrix === copy );
 * // log : false
 *
 * @returns { Matrix } - Returns copy of the Matrix.
 * @method clone
 * @throws { Error } If arguments is passed.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function clone()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  let dst = _.Copyable.prototype.clone.call( self );

  if( dst.buffer === self.buffer )
  dst[ bufferSymbol ] = _.longSlice( dst.buffer );

  return dst;
}

//

/**
 * Static routine CopyTo() copies data from buffer {-src-} into buffer {-dst-}.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 2, 2 ] );
 * console.log( matrix.toStr() );
 * var copy = _.Matrix.CopyTo( matrix, [ 1, 2, 3, 4 ] );
 * console.log( copy.toStr() );
 * // log : +1, +2,
 * //       +3, +4,
 * console.log( matrix === copy );
 * // log : true
 *
 * @param { Long|VectorAdapter|Matrix } dst - Destination container.
 * @param { Long|VectorAdapter|Matrix } src - Source container.
 * @returns { Long|VectorAdapter|Matrix } - Returns original instance of destination container filled by values of source container.
 * @throws { Error } If arguments.length is not equal to two.
 * @throws { Error } If {-dst-} and {-src-} have different dimensions.
 * @throws { Error } If routine is called by instance of Matrix.
 * @static
 * @function CopyTo
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function CopyTo( dst, src )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( dst === src )
  return dst;

  let odst = dst;
  let dstDims = Self.DimsOf( dst );
  let srcDims = Self.DimsOf( src );

  _.assert( _.longIdentical( srcDims, dstDims ), '(-src-) and (-dst-) should have same dimensions' );

  if( !_.matrixIs( src ) )
  {

    src = this.vectorAdapter.from( src );
    if( _.longIs( dst ) )
    dst = this.vectorAdapter.from( dst );

    if( _.vectorAdapterIs( dst ) )
    for( let s = 0 ; s < src.length ; s += 1 )
    dst.eSet( s, src.eGet( s ) )
    else if( _.matrixIs( dst ) )
    for( let s = 0 ; s < src.length ; s += 1 )
    dst.scalarSet( [ s, 0 ], src.eGet( s ) )
    else _.assert( 0, 'unknown type of (-dst-)', _.strType( dst ) );

    return odst;
  }
  else
  {

    let dstDims = Self.DimsOf( dst );
    let srcDims = Self.DimsOf( src );

    if( _.matrixIs( dst ) )
    src.scalarEach( function( it )
    {
      dst.scalarSet( it.indexNd , it.scalar );
    });
    else if( _.vectorAdapterIs( dst ) )
    src.scalarEach( function( it )
    {
      dst.eSet( it.indexFlat , it.scalar );
    });
    else if( _.longIs( dst ) )
    src.scalarEach( function( it )
    {
      dst[ it.indexFlat ] = it.scalar;
    });
    else _.assert( 0, 'unknown type of (-dst-)', _.strType( dst ) );

  }

  return odst;
}

//

/**
 * Method extractNormalized() extracts data from the Matrix instance and saves it in new map.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var extract = matrix.extractNormalized();
 * console.log( extract );
 * // log : {
 * //         buffer : [ 1, 2, 3, 4 ],
 * //         offset : 0,
 * //         strides : 1, 2,
 * //        }
 *
 * @returns { Map } - Returns map with matrix data.
 * @method extractNormalized
 * @throws { Error } If arguments is passed.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function extractNormalized()
{
  let self = this;
  let result = Object.create( null );

  _.assert( arguments.length === 0, 'Expects no arguments' );

  result.buffer = self.long.longMakeUndefined( self.buffer , self.scalarsPerMatrix );
  result.offset = 0;
  result.strides = self.StridesForDimensions( self.dims, self.inputTransposing );

  self.scalarEach( function( it )
  {
    let i = self._FlatScalarIndexFromIndexNd( it.indexNd, result.strides );
    result.buffer[ i ] = it.scalar;
  });

  return result;
}

//

/**
 * Method toStr() converts current matrix to string.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var got = matrix.toStr();
 * console.log( got );
 * // log : +1, +2,\n+3, +4,
 *
 * @param { Map } o - Options map.
 * @param { String } o.tab - String inserted before each new line.
 * @param { Number } o.precision -  Precision of scalar values.
 * @param { Boolean } o.usingSign - Prepend sign to scalar values.
 * @returns { String } - Returns formatted string that represents matrix of scalars.
 * @method toStr
 * @throws { Error } If options map {-o-} has unknown options.
 * @throws { Error } If options map {-o-} is not map like.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function toStr( o )
{
  let self = this;
  let result = '';

  o = o || Object.create( null );
  _.routineOptions( toStr, o );

  let l = self.dims[ 0 ];
  let scalarsPerRow, scalarsPerCol;
  let col, row;
  let m, c, r, e;

  let isInt = true;
  self.scalarEach( function( it )
  {
    isInt = isInt && _.intIs( it.scalar );
  });

  /* */

  function eToStr()
  {
    let e = row.eGet( c );

    if( isInt )
    {
      if( !o.usingSign || e < 0 )
      result += e.toFixed( 0 );
      else
      result += '+' + e.toFixed( 0 );
    }
    else
    {
      result += e.toFixed( o.precision );
    }

    result += ', ';

  }

  /* */

  function rowToStr()
  {

    if( m === undefined )
    row = self.rowGet( r );
    else
    row = self.rowVectorOfMatrixGet( [ m ], r );

    if( scalarsPerRow === Infinity )
    {
      e = 0;
      eToStr();
      result += '*Infinity';
    }
    else for( c = 0 ; c < scalarsPerRow ; c += 1 )
    eToStr();

  }

  /* */

  function matrixToStr( m )
  {

    scalarsPerRow = self.scalarsPerRow;
    scalarsPerCol = self.scalarsPerCol;

    if( scalarsPerCol === Infinity )
    {
      r = 0;
      rowToStr( 0 );
      result += ' **Infinity';
    }
    else for( r = 0 ; r < scalarsPerCol ; r += 1 )
    {
      rowToStr( r );
      if( r < scalarsPerCol - 1 )
      result += '\n' + o.tab;
    }

  }

  /* */

  if( self.dims.length === 2 )
  {

    matrixToStr();

  }
  else if( self.dims.length === 3 )
  {

    for( m = 0 ; m < l ; m += 1 )
    {
      result += 'Slice ' + m + ' :\n';
      matrixToStr( m );
    }

  }
  else _.assert( 0, 'not implemented' );

  return result;
}

toStr.defaults =
{
  tab : '',
  precision : 3,
  usingSign : 1,
}

toStr.defaults.__proto__ = _.toStr.defaults;

// --
// size in bytes
// --

function _sizeGet()
{
  let result = this.sizeOfAtom*this.scalarsPerMatrix;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfElementGet()
{
  let result = this.sizeOfAtom*this.scalarsPerElement;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfElementStrideGet()
{
  let result = this.sizeOfAtom*this.strideOfElement;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfColGet()
{
  let result = this.sizeOfAtom*this.scalarsPerCol;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfColStrideGet()
{
  let result = this.sizeOfAtom*this.strideOfCol;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfRowGet()
{
  let result = this.sizeOfAtom*this.scalarsPerRow;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfRowStrideGet()
{
  let result = this.sizeOfAtom*this.strideOfRow;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfAtomGet()
{
  _.assert( !!this.buffer );
  let result = this.buffer.BYTES_PER_ELEMENT;
  _.assert( result >= 0 );
  return result;
}

// --
// size in scalars
// --

function _scalarsPerElementGet()
{
  let self = this;
  return self[ scalarsPerElementSymbol ];
}

//

function _scalarsPerColGet()
{
  let self = this;
  let result = self.dims[ 0 ];
  _.assert( result >= 0 );
  return result;
}

//

function _scalarsPerRowGet()
{
  let self = this;
  let result = self.dims[ 1 ];
  _.assert( result >= 0 );
  return result;
}

//

function _nrowGet()
{
  let self = this;
  let result = self.dims[ 0 ];
  _.assert( result >= 0 );
  return result;
}

//

function _ncolGet()
{
  let self = this;
  let result = self.dims[ 1 ];
  _.assert( result >= 0 );
  return result;
}

//

function _scalarsPerMatrixGet()
{
  let self = this;
  let result = self.length === Infinity ? self.scalarsPerElement : self.length * self.scalarsPerElement;
  _.assert( _.numberIsFinite( result ) );
  _.assert( result >= 0 );
  return result;
}

//


/**
 * Static routine ScalarsPerMatrixForDimensions() calculates quantity of scalars in matrix with defined dimensions.
 *
 * @example
 * var scalars = _.Matrix.ScalarsPerMatrixForDimensions( [ 2, 2 ] );
 * console.log( scalars );
 * // log : 4
 *
 * @param { Array } dims - An array with matrix dimensions.
 * @returns { Number } - Returns quantity of scalars in matrix with defined dimensions.
 * @throws { Error } If arguments.length is not equal to one.
 * @throws { Error } If {-dims-} is not an Array.
 * @throws { Error } If routine is called by instance of Matrix.
 * @static
 * @function ScalarsPerMatrixForDimensions
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function ScalarsPerMatrixForDimensions( dims )
{
  let result = 1;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayIs( dims ) );
  // _.assert( !_.instanceIs( this ) )

  for( let d = dims.length-1 ; d >= 0 ; d-- )
  {
    _.assert( dims[ d ] >= 0 )
    result *= dims[ d ];
  }

  return result;
}

//

/**
 * Static routine NrowOf() returns number of rows in source Matrix {-src-}.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 3, 5 ] );
 * var rows = _.Matrix.NrowOf( matrix );
 * console.log( rows );
 * // log : 3
 *
 * @param { Matrix|VectorAdapter|Long } src - Source matrix or Long.
 * @returns { Number } - Returns quantity of rows in source matrix.
 * @throws { Error } If {-src-} is not a Matrix, not a Long.
 * @static
 * @function NrowOf
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function NrowOf( src )
{
  if( src instanceof Self )
  return src.dims[ 0 ];
  if( _.numberIs( src ) )
  return 1;
  _.assert( src.length );
  return src.length;
}

//

/**
 * Static routine NcolOf() returns number of columns in source Matrix {-src-}.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 3, 5 ] );
 * var cols = _.Matrix.NcolOf( matrix );
 * console.log( cols );
 * // log : 5
 *
 * @param { Matrix|VectorAdapter|Long } src - Source matrix or Long.
 * @returns { Number } - Returns quantity of columns in source matrix.
 * @throws { Error } If {-src-} is not a Matrix, not a VectorAdapter, not a Long.
 * @static
 * @function NcolOf
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function NcolOf( src )
{
  if( src instanceof Self )
  return src.dims[ 1 ];
  if( _.numberIs( src ) )
  return 1;
  _.assert( src.length >= 0 );
  return 1;
}

//

/**
 * Static routine DimsOf() returns dimentions of source Matrix {-src-}.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 3, 5 ] );
 * var dims = _.Matrix.DimsOf( matrix );
 * console.log( dims );
 * // log : [ 3, 5 ]
 *
 * @param { Matrix|VectorAdapter|Long } src - Source matrix or Long.
 * @returns { Array } - Returns dimensions in source matrix.
 * @throws { Error } If {-src-} is not a Matrix, not a VectorAdapter, not a Long.
 * @static
 * @function DimsOf
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function DimsOf( src )
{
  if( src instanceof Self )
  return src.dims.slice();
  if( _.numberIs( src ) )
  return [ 1, 1 ];
  let result = [ 0, 1 ];
  _.assert( !!src && src.length >= 0 );
  result[ 0 ] = src.length;
  return result;
}

/**
 * Method flatScalarIndexFrom() finds the index of element in the matrix buffer.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var got = matrix.flatScalarIndexFrom( [ 1, 1 ] );
 * console.log( got );
 * // log : 4
 *
 * @param { Array } indexNd - The position of element.
 * @returns { Number } - Returns flat index of element.
 * @method flatScalarIndexFrom
 * @throws { Error } If arguments.length is not equal to one.
 * @throws { Error } If {-src-} is not an Array.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function flatScalarIndexFrom( indexNd )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._FlatScalarIndexFromIndexNd( indexNd, self._stridesEffective );

  return result + self.offset;
}

//

function _FlatScalarIndexFromIndexNd( indexNd, strides )
{
  let result = 0;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.arrayIs( indexNd ) );
  _.assert( _.arrayIs( strides ) );
  _.assert( indexNd.length === strides.length );

  for( let i = 0 ; i < indexNd.length ; i++ )
  {
    result += indexNd[ i ]*strides[ i ];
  }

  return result;
}

//

/**
 * Method flatGranuleIndexFrom() finds the index offset of element in the matrix buffer.
 * Method takes into account values of definition of element position {-indexNd-}.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var got = matrix.flatGranuleIndexFrom( [ 1, 1 ] );
 * console.log( got );
 * // log : 3
 *
 * @param { Long|VectorAdapter|Matrix } indexNd - The position of element.
 * @returns { Number } - Returns index offset of element.
 * @method flatGranuleIndexFrom
 * @throws { Error } If arguments.length is not equal to one.
 * @throws { Error } If indexNd.length is not equal to strides length.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function flatGranuleIndexFrom( indexNd )
{
  let self = this;
  let result = 0;
  let stride = 1;
  // let d = self._stridesEffective.length-indexNd.length; /* Dmytro : duplicated below, not used */

  debugger;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( indexNd.length <= self._stridesEffective.length );

  let f = self._stridesEffective.length - indexNd.length;
  // for( let i = indexNd.length-1 ; i >= 0 ; i-- )
  for( let i = f ; i < indexNd.length ; i++ )
  {
    stride = self._stridesEffective[ i ];
    result += indexNd[ i-f ]*stride;
  }

  return result;
}

// --
// stride
// --

function _lengthGet()
{
  return this[ lengthSymbol ];
}

//

function _occupiedRangeGet()
{
  return this[ occupiedRangeSymbol ];
}

//

function _stridesEffectiveGet()
{
  return this[ stridesEffectiveSymbol ];
}

//

function _stridesSet( src )
{
  let self = this;

  // _.assert( _.longIs( src ) || _.numberIs( src ) || src === null );
  _.assert( _.longIs( src ) || src === null );

  if( _.longIs( src ) )
  src = _.longSlice( src );

  self[ stridesSymbol ] = src;

  self._sizeChanged();

}

//

function _strideOfElementGet()
{
  return this._stridesEffective[ this._stridesEffective.length-1 ];
}

//

function _strideOfColGet()
{
  return this._stridesEffective[ 1 ];
}

//

function _strideInColGet()
{
  return this._stridesEffective[ 0 ];
}

//

function _strideOfRowGet()
{
  return this._stridesEffective[ 0 ];
}

//

function _strideInRowGet()
{
  return this._stridesEffective[ 1 ];
}

//

/**
 * Static routine StridesForDimensions() calculates strides for each dimension taking into account transposing value.
 *
 * @example
 * var strides = _.Matrix.StridesForDimensions( [ 2, 2 ], true );
 * console.log( strides );
 * // log : [ 2, 1 ]
 *
 * @param { Array } dims - Dimensions of a matrix.
 * @param { BoolLike } transposing - Options defines transposing of the matrix.
 * @returns { Array } - Returns strides for each dimension of the matrix.
 * @throws { Error } If arguments.length is not equal to two.
 * @throws { Error } If {-dims-} is not an Array.
 * @throws { Error } If {-transposing-} is not BoolLike.
 * @throws { Error } If elements of {-dims-} is negative number.
 * @static
 * @function StridesForDimensions
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function StridesForDimensions( dims, transposing )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.arrayIs( dims ) );
  _.assert( _.boolLike( transposing ) );
  _.assert( dims[ 0 ] >= 0 );
  _.assert( dims[ dims.length-1 ] >= 0 );

  let strides = dims.slice();

  if( transposing )
  {
    strides.push( 1 );
    strides.splice( 0, 1 );
    _.assert( strides[ 1 ] > 0 );
    _.assert( strides[ strides.length-1 ] > 0 );
    for( let i = strides.length-2 ; i >= 0 ; i-- )
    strides[ i ] = strides[ i ]*strides[ i+1 ];
  }
  else
  {
    strides.splice( strides.length-1, 1 );
    strides.unshift( 1 );
    _.assert( strides[ 0 ] > 0 );
    _.assert( strides[ 1 ] >= 0 );
    for( let i = 1 ; i < strides.length ; i++ )
    strides[ i ] = strides[ i ]*strides[ i-1 ];
  }

  /* */

  if( dims[ 0 ] === Infinity )
  strides[ 0 ] = 0;
  if( dims[ 1 ] === Infinity )
  strides[ 1 ] = 0;

  return strides;
}

//

/**
 * Static routine StridesRoll() calculates strides offset for each dimension.
 *
 * @example
 * var strides = _.Matrix.StridesRoll( [ 2, 2 ] );
 * console.log( strides );
 * // log : [ 4, 2 ]
 *
 * @param { Array } strides - Strides of a matrix.
 * @returns { Array } - Returns strides for each dimension of the matrix.
 * @throws { Error } If arguments.length is not equal to one.
 * @static
 * @function StridesRoll
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function StridesRoll( strides )
{

  _.assert( arguments.length === 1, 'Expects single argument' );

  for( let s = strides.length-2 ; s >= 0 ; s-- )
  strides[ s ] = strides[ s+1 ]*strides[ s ];

  return strides;
}

// --
// buffer
// --

function _bufferSet( src )
{
  let self = this;

  if( self[ bufferSymbol ] === src )
  return;

  if( _.numberIs( src ) )
  src = this.long.longMake([ src ]);

  _.assert( _.longIs( src ) || src === null );

  // if( src )
  // debugger;

  self[ bufferSymbol ] = src;

  if( !self._changing[ 0 ] )
  self[ dimsSymbol ] = null;

  self._sizeChanged();
}

//

function _offsetSet( src )
{
  let self = this;

  _.assert( _.numberIs( src ) );

  self[ offsetSymbol ] = src;

  self._sizeChanged();

}

//

function _bufferAssign( src )
{
  let self = this;
  self._changeBegin();

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.longIs( src ) );
  _.assert( self.scalarsPerMatrix === src.length, 'matrix', self.dims, 'should have', self.scalarsPerMatrix, 'scalars, but got', src.length );

  self.scalarEach( function( it )
  {
    self.scalarSet( it.indexNd, src[ it.indexFlatRowFirst ] );
  });

  self._changeEnd();
  return self;
}

//

/**
 * Method bufferCopyTo() copies content of the matrix to the buffer {-dst-}.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var dst = [ 0, 0, 0, 0 ];
 * var got = matrix.bufferCopyTo( dst );
 * console.log( got );
 * // log : [ 1, 2, 3, 4 ]
 * console.log( got === dst );
 * // log : true
 *
 * @param { Long } dst - Destination buffer.
 * @returns { Long } - Returns destination buffer filled by values of matrix buffer.
 * If {-dst-} is undefined, then method returns copy of matrix buffer.
 * @method bufferCopyTo
 * @throws { Error } If arguments.length is more then one.
 * @throws { Error } If {-dst-} is not a Long.
 * @throws { Error } If number of elements in matrix is not equal to dst.length.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */


function bufferCopyTo( dst )
{
  let self = this;
  let scalarsPerMatrix = self.scalarsPerMatrix;

  if( !dst )
  dst = self.long.longMakeUndefined( self.buffer, scalarsPerMatrix );

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.longIs( dst ) );
  _.assert( scalarsPerMatrix === dst.length, 'matrix', self.dims, 'should have', scalarsPerMatrix, 'scalars, but got', dst.length );

  throw _.err( 'not tested' );

  self.scalarEach( function( it )
  {
    dst[ it.indexFlat ] = it.scalar;
  });

  return dst;
}

//

/**
 * Method bufferNormalize() normalizes buffer of current matrix.
 * Method replaces current matrix buffer by new buffer with only elements of matrix.
 *
 * @example
 * var matrix = _.Matrix
 * ({
 *    buffer : [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
 *    dims : [ 2, 2 ],
 *    strides : [ 1, 2 ]
 * });
 * console.log( matrix.buffer );
 * // log : [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
 * matrix.bufferNormalize();
 * console.log( matrix.buffer );
 * // log : [ 1, 2, 3, 4 ]
 *
 * @returns { Undefined } - Returns not a value, changes buffer of current matrix.
 * @method bufferNormalize
 * @throws { Error } If argument is provided.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function bufferNormalize()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  let buffer = self.long.longMakeUndefined( self.buffer, self.scalarsPerMatrix );

  let i = 0;
  self.scalarEach( function( it )
  {
    buffer[ i ] = it.scalar;
    i += 1;
  });

  self.copy
  ({
    buffer,
    offset : 0,
    inputTransposing : 0,
  });

}

// --
// reshaping
// --

function _changeBegin()
{
  let self = this;

  self._changing[ 0 ] += 1;

}

//

function _changeEnd()
{
  let self = this;

  self._changing[ 0 ] -= 1;
  self._sizeChanged();

}

//

function _sizeChanged()
{
  let self = this;

  if( self._changing[ 0 ] )
  return;

  self._adjust();

}

//

function _adjust()
{
  let self = this;

  self._adjustVerify();
  self._adjustAct();
  self._adjustValidate();

}

//

function _adjustAct()
{
  let self = this;
  let changed = false;

  self._changing[ 0 ] += 1;

  /* adjust breadth */

  if( _.numberIs( self.breadth ) )
  {
    debugger;
    self.breadth = [ self.breadth ];
    changed = true;
  }

  /* strides */

  if( _.numberIs( self.strides ) )
  {
    debugger;
    let strides = _.dup( 1, self.breadth.length+1 );
    strides[ strides.length-1 ] = self.strides;
    self.strides = self.StridesRoll( strides );
    changed = true;
  }

  self[ stridesEffectiveSymbol ] = null;

  if( self.strides )
  {
    self[ stridesEffectiveSymbol ] = self.strides;
  }

  /* dims */

  _.assert( self.dims === null || _.longIs( self.dims ) );

  if( !self.dims )
  {
    if( self._dimsWas )
    {
      _.assert( _.arrayIs( self._dimsWas ) );
      _.assert( _.arrayIs( self._dimsWas ) );
      _.assert( _.longIs( self.buffer ) );
      _.assert( self.offset >= 0 );

      let dims = self._dimsWas.slice();
      dims[ self.growingDimension ] = 1;
      let ape = _.avector.reduceToProduct( dims );
      let l = ( self.buffer.length - self.offset ) / ape;
      dims[ self.growingDimension ] = l;
      self[ dimsSymbol ] = dims;

      _.assert( l >= 0 );
      _.assert( _.intIs( l ) );

    }
    else if( self.strides )
    {
      _.assert( 0, 'Cant deduce dims from strides' );
    }
    else
    {
      _.assert( _.longIs( self.buffer ), 'Expects buffer' );
      if( self.buffer.length - self.offset > 0 )
      {
        self[ dimsSymbol ] = [ self.buffer.length - self.offset, 1 ];
        if( !self._stridesEffective )
        self[ stridesEffectiveSymbol ] = [ 1, self.buffer.length - self.offset ];
      }
      else
      {
        self[ dimsSymbol ] = [ 1, 0 ];
        if( !self._stridesEffective )
        self[ stridesEffectiveSymbol ] = [ 1, 1 ];
      }
      changed = true;
    }
  }

  _.assert( _.arrayIs( self.dims ) );

  self._dimsWas = self.dims.slice();

  self[ breadthSymbol ] = self.dims.slice( 0, self.dims.length-1 );
  self[ lengthSymbol ] = self.dims[ self.dims.length-1 ];

  /* strides */

  if( !self._stridesEffective )
  {

    _.assert( _.boolLike( self.inputTransposing ), 'If field {- matrix.strides -} is not spefified explicitly then field {- matrix.inputTransposing -} should be specified explicitly.' );
    _.assert( self.dims[ 0 ] >= 0 );
    _.assert( self.dims[ self.dims.length-1 ] >= 0 );

    let strides = self[ stridesEffectiveSymbol ] = self.StridesForDimensions( self.dims, self.inputTransposing );

  }

  _.assert( self._stridesEffective.length >= 2 );

  /* scalars per element */

  _.assert( self.breadth.length === 1, 'not tested' );
  self[ scalarsPerElementSymbol ] = _.avector.reduceToProduct( self.breadth );

  /* buffer region */

  let dims = self.dims;
  let offset = self.offset;
  let occupiedRange = [ 0, 0 ];

  if( self.length !== 0 )
  {
    let extreme = [ 0, 0 ];

    for( let s = 0 ; s < self._stridesEffective.length ; s++ )
    {
      if( dims[ s ] === Infinity )
      continue;

      let delta = dims[ s ] > 0 ? self._stridesEffective[ s ]*( dims[ s ]-1 ) : 0;

      if( delta >= 0 )
      extreme[ 1 ] = extreme[ 1 ] + delta;
      else
      extreme[ 0 ] = extreme[ 0 ] + delta;

    }

    occupiedRange[ 0 ] += extreme[ 0 ];
    occupiedRange[ 1 ] += extreme[ 1 ];

  }

  occupiedRange[ 0 ] += offset;
  occupiedRange[ 1 ] += offset;
  occupiedRange[ 1 ] += 1;

  self[ occupiedRangeSymbol ] = occupiedRange;

  if( self.scalarsPerMatrix )
  if( self.buffer.length )
  {
    _.assert( 0 <= occupiedRange[ 0 ] && occupiedRange[ 0 ] < self.buffer.length );
    _.assert( 0 <= occupiedRange[ 1 ] && occupiedRange[ 1 ] <= self.buffer.length );
  }

  /* done */

  _.entityFreeze( self.dims );
  _.entityFreeze( self.breadth );
  _.entityFreeze( self._stridesEffective );

  self._changing[ 0 ] -= 1;

}

//

function _adjustVerify()
{
  let self = this;

  _.assert( _.longIs( self.buffer ), 'matrix needs buffer' );
  _.assert( _.longIs( self.strides ) || self.strides === null );
  _.assert( _.numberIs( self.offset ), 'matrix needs offset' );

}

//

function _adjustValidate()
{
  let self = this;

  _.assert( _.arrayIs( self.breadth ) );
  _.assert( self.dims.length === self.breadth.length+1 );
  _.assert( _.arrayIs( self.dims ) );
  _.assert( _.arrayIs( self.breadth ) );

  _.assert( self.length >= 0 );
  _.assert( self.scalarsPerElement >= 0 );
  // _.assert( self.strideOfElement >= 0 );

  _.assert( _.longIs( self.buffer ) );
  _.assert( _.longIs( self.breadth ) );

  _.assert( _.longIs( self._stridesEffective ) );
  _.assert( _.numbersAreInt( self._stridesEffective ) );
  // _.assert( _.numbersArePositive( self._stridesEffective ) );
  _.assert( self._stridesEffective.length >= 2 );

  _.assert( _.numbersAreInt( self.dims ) );
  _.assert( _.numbersArePositive( self.dims ) );

  _.assert( _.intIs( self.length ) );
  _.assert( self.length >= 0 );
  _.assert( self.dims[ self.dims.length-1 ] === self.length );

  _.assert( self.breadth.length+1 === self._stridesEffective.length );

  if( Config.debug )
  for( let d = 0 ; d < self.dims.length-1 ; d++ )
  _.assert( self.dims[ d ] >= 0 );

  if( Config.debug )
  if( self.scalarsPerMatrix > 0 && _.numberIsFinite( self.length ) )
  for( let d = 0 ; d < self.dims.length ; d++ )
  _.assert( self.offset + ( self.dims[ d ]-1 )*self._stridesEffective[ d ] <= self.buffer.length, 'out of bound' );

}

//

function _breadthGet()
{
  let self = this;
  return self[ breadthSymbol ];
}

//

function _breadthSet( breadth )
{
  let self = this;

  if( _.numberIs( breadth ) )
  breadth = [ breadth ];
  else if( _.bufferTypedIs( breadth ) )
  breadth = _.arrayFrom( breadth );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( breadth === null || _.arrayIs( breadth ), 'Expects array (-breadth-) but got', _.strType( breadth ) );

  if( breadth === self.breadth )
  return;

  if( breadth !== null && self.breadth !== null )
  if( _.longIdentical( self.breadth, breadth ) )
  return;

  self._changeBegin();

  if( breadth === null )
  {
    debugger;
    if( self[ dimsSymbol ] === null )
    debugger;
    self[ breadthSymbol ] = null
    if( self[ dimsSymbol ] === null )
    self._dimsWas = null;
  }
  else
  {
    let _dimsWas = breadth.slice();
    _dimsWas.push( self._dimsWas ? self._dimsWas[ self._dimsWas.length-1 ] : 0 );
    self[ breadthSymbol ] = _.entityFreeze( breadth.slice() );
    self[ dimsSymbol ] = null;
    self._dimsWas = _dimsWas;
  }

  self._changeEnd();
}

//

function _dimsSet( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( src )
  {

    _.assert( _.arrayIs( src ) );
    _.assert( src.length >= 2 );
    _.assert( _.numbersAreInt( src ) );
    _.assert( src[ 0 ] >= 0 );
    _.assert( src[ src.length-1 ] >= 0 );
    self[ dimsSymbol ] = _.entityFreeze( src.slice() );
    self[ breadthSymbol ] = _.entityFreeze( src.slice( 0, src.length-1 ) );

  }
  else
  {
    self[ dimsSymbol ] = null;
    self[ breadthSymbol ] = null;
  }

  _.assert( self[ dimsSymbol ] === null || _.numbersAreInt( self[ dimsSymbol ] ) );

  self._sizeChanged();

  return src;
}

//

/**
 * Static routine ShapesAreSame() compares dimensions of two matrices {-ins1-} and {-ins-}.
 *
 * @example
 * var matrix1 = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var matrix2 = _.Matrix.Make( [ 2, 2 ] );
 * var got = _.Matrix.ShapesAreSame( matrix1, matrix2 );
 * console.log( got );
 * // log : true
 *
 * @param { Matrix|VectorAdapter|Long } ins1 - The source matrix.
 * @param { Matrix|VectorAdapter|Long } ins2 - The source matrix.
 * @returns { Boolean } - Returns value whether are dimensions of two matrices the same.
 * @throws { Error } If routine is called by instance of Matrix.
 * @static
 * @function ShapesAreSame
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function ShapesAreSame( ins1, ins2 )
{
  // _.assert( !_.instanceIs( this ) );

  let dims1 = this.DimsOf( ins1 );
  let dims2 = this.DimsOf( ins2 );

  return _.longIdentical( dims1, dims2 );
}

//

/**
 * Method hasShape() compares dimensions of instance with dimensions of source container {-src-}.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare( [ 1, 2, 3, 4 ] );
 * var got = matrix.hasShape( [ 2, 2 ] );
 * console.log( got );
 * // log : true
 *
 * @param { Array|Matrix } src - The container with dimensions.
 * @returns { Boolean } - Returns value whether are dimensions of two matrices the same.
 * @method hasShape
 * @throws { Error } If arguments.length is not equal to one.
 * @throws { Error } If {-src-} is not an Array, not a Matrix.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function hasShape( src )
{
  let self = this;

  // src = Self.DimsOf( src );

  if( src instanceof Self )
  src = src.dims;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayIs( src ) );

  return _.longIdentical( self.dims, src );
}

// --
// relations
// --

let offsetSymbol = Symbol.for( 'offset' );
let bufferSymbol = Symbol.for( 'buffer' );
let breadthSymbol = Symbol.for( 'breadth' );
let dimsSymbol = Symbol.for( 'dims' );

let stridesSymbol = Symbol.for( 'strides' );
let lengthSymbol = Symbol.for( 'length' );
let stridesEffectiveSymbol = Symbol.for( '_stridesEffective' );

let scalarsPerElementSymbol = Symbol.for( 'scalarsPerElement' );
let occupiedRangeSymbol = Symbol.for( 'occupiedRange' );

//

let Composes =
{

  dims : null,
  growingDimension : 1,
  inputTransposing : null,

}

//

let Aggregates =
{
  buffer : null,
}

//

let Associates =
{
}

//

let Restricts =
{

  _dimsWas : null,
  _changing : [ 1 ],

}

//

let Medials =
{

  // buffer : null,
  strides : null,
  offset : 0,
  breadth : null,

}

//

let Statics =
{

  /* */

  Is,
  CopyTo,

  ScalarsPerMatrixForDimensions,
  NrowOf, /* qqq : cover routine NrowOf. should work for any vector, matrix and scalar */
  NcolOf, /* qqq : cover routine NcolOf. should work for any vector, matrix and scalar */
  DimsOf, /* qqq : cover routine DimsOf. should work for any vector, matrix and scalar */
  _FlatScalarIndexFromIndexNd,

  StridesForDimensions,
  StridesRoll,

  ShapesAreSame,

  /* var */

  vectorAdapter : _.vectorAdapter,

}

//

let Forbids =
{

  stride : 'stride',

  strideInBytes : 'strideInBytes',
  strideInAtoms : 'strideInAtoms',

  stridePerElement : 'stridePerElement',
  lengthInStrides : 'lengthInStrides',

  dimensions : 'dimensions',
  dimensionsWithLength : 'dimensionsWithLength',
  stridesEffective : 'stridesEffective',

  colLength : 'colLength',
  rowLength : 'rowLength',

  _generator : '_generator',
  usingOptimizedAccessors : 'usingOptimizedAccessors',
  dimensionsDesired : 'dimensionsDesired',
  array : 'array',

}

//

let ReadOnlyAccessors =
{

  /* size in bytes */

  size : 'size',
  sizeOfElement : 'sizeOfElement',
  sizeOfElementStride : 'sizeOfElementStride',
  sizeOfCol : 'sizeOfCol',
  sizeOfColStride : 'sizeOfColStride',
  sizeOfRow : 'sizeOfRow',
  sizeOfRowStride : 'sizeOfRowStride',
  sizeOfAtom : 'sizeOfAtom',

  /* size in scalars */

  scalarsPerElement : 'scalarsPerElement', /*  cached*/
  scalarsPerCol : 'scalarsPerCol',
  scalarsPerRow : 'scalarsPerRow',
  ncol : 'ncol',
  nrow : 'nrow',
  scalarsPerMatrix : 'scalarsPerMatrix',

  /* length */

  length : 'length', /* cached */
  occupiedRange : 'occupiedRange', /* cached */
  _stridesEffective : '_stridesEffective', /* cached */

  strideOfElement : 'strideOfElement',
  strideOfCol : 'strideOfCol',
  strideInCol : 'strideInCol',
  strideOfRow : 'strideOfRow',
  strideInRow : 'strideInRow',

}

//

let Accessors =
{

  buffer : 'buffer',
  offset : 'offset',

  strides : 'strides',
  dims : 'dims',
  breadth : 'breadth',

}

// --
// declare
// --

let Extension =
{

  // inter

  init,
  Is,
  _traverseAct,
  _equalAre,
  _longGet,

  // import / export

  _copy,
  copy,

  copyFromScalar,
  copyFromBuffer,
  clone,

  CopyTo,
  extractNormalized,
  toStr,

  // size in bytes

  _sizeGet,

  _sizeOfElementGet,
  _sizeOfElementStrideGet,

  _sizeOfColGet,
  _sizeOfColStrideGet,

  _sizeOfRowGet,
  _sizeOfRowStrideGet,

  _sizeOfAtomGet,

  // length in scalars

  _scalarsPerElementGet, /* cached */
  _scalarsPerColGet,
  _scalarsPerRowGet,
  _nrowGet,
  _ncolGet,
  _scalarsPerMatrixGet,

  ScalarsPerMatrixForDimensions,
  NrowOf,
  NcolOf,
  DimsOf,

  flatScalarIndexFrom,
  _FlatScalarIndexFromIndexNd,
  flatGranuleIndexFrom,

  // stride

  _lengthGet, /* cached */
  _occupiedRangeGet, /* cached */

  _stridesEffectiveGet, /* cached */
  _stridesSet, /* cached */

  _strideOfElementGet,
  _strideOfColGet,
  _strideInColGet,
  _strideOfRowGet,
  _strideInRowGet,

  StridesForDimensions,
  StridesRoll,

  // buffer

  _bufferSet, /* cached */
  _offsetSet, /* cached */

  _bufferAssign,
  bufferCopyTo,

  bufferNormalize,

  // reshaping

  _changeBegin,
  _changeEnd,

  _sizeChanged,

  _adjust,
  _adjustAct,
  _adjustVerify,
  _adjustValidate,

  _breadthGet, /* cached */
  _breadthSet,
  _dimsSet, /* cached */

  ShapesAreSame,
  hasShape,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Medials,
  Statics,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

_.Copyable.mixin( Self );

Object.defineProperty( Self, 'accuracy',
{
  get : function() { return this.vectorAdapter.accuracy },
});

Object.defineProperty( Self, 'accuracySqr',
{
  get : function() { return this.vectorAdapter.accuracySqr },
});

Object.defineProperty( Self.prototype, 'accuracy',
{
  get : function() { return this.vectorAdapter.accuracy },
});

Object.defineProperty( Self.prototype, 'accuracySqr',
{
  get : function() { return this.vectorAdapter.accuracySqr },
});

_.Matrix = Self;

//

_.assert( !!_.vectorAdapter );
_.assert( !!_.vectorAdapter.long );

_.assert( _.objectIs( _.withDefaultLong ) );
_.assert( _.objectIs( _.withDefaultLong.Fx ) );

_.accessor.readOnly( Self.prototype, ReadOnlyAccessors );
_.accessor.readOnly( Self, { long : { getter : _longGet, setter : false } } );
_.accessor.readOnly( Self.prototype, { long : { getter : _longGet, setter : false } } );

_.assert( Self.prototype.vectorAdapter.long === Self.vectorAdapter.long );
_.assert( Self.long === Self.vectorAdapter.long );
_.assert( Self.prototype.long === Self.vectorAdapter.long );
_.assert( Self.long === _.vectorAdapter.long );

})();
