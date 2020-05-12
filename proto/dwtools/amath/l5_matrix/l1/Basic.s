(function _Basic_s_() {

'use strict';

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

/**
 * Method init() initializes the instance of matrix and set value for options.
 *
 * @example
 * var matrix = _.Matrix
 * ({
 *   buffer : [ 1, 2, 3, 4, 5, 6, 7, 8 ],
 *   dims : [ 2, 2 ],
 *   strides : [ 2, 1 ];
 * });
 * console.log( matrix.inputRowMajor );
 * // log : null
 * matrix.init( { inputRowMajor : 1 } );
 * console.log( matrix.inputRowMajor );
 * // log : 1
 *
 * @param { MapLike } o - Options map.
 * @returns { Matrix } - Returns original instance of Matrix with changed options.
 * @method init
 * @throws { Error } If arguments.length is more then one.
 * @throws { Error } If {-o-} is not a MapLike.
 * @throws { Error } If {-o-} has extra options.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function init( o )
{
  let self = this;

  self._changing = [ 1 ];

  self[ stridesEffectiveSymbol ] = null;
  self[ lengthSymbol ] = null;
  self[ scalarsPerElementSymbol ] = null;
  self[ scalarsPerSliceSymbol ] = null
  self[ scalarsPerMatrixSymbol ] = null;
  self[ slicesPerMatrixSymbol ] = null;
  self[ occupiedRangeSymbol ] = null;
  self[ dimsEffectiveSymbol ] = null;
  self[ stridesSymbol ] = null;
  self[ offsetSymbol ] = 0;

  _.workpiece.initFields( self );

  Object.preventExtensions( self );

  self._changing[ 0 ] -= 1;

  if( o )
  {
    self.copy( o );
  }
  else
  {
    self._sizeChanged();
  }

  _.assert( arguments.length <= 1 );

}

//

/**
 * Static routine Is() checks whether the provided argument is an instance of Matrix.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
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

function _traverseAct( it ) /* zzz : deprecate */
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
  if( dst.stridesEffective )
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
      if( src.offset !== undefined )
      dst.offset = src.offset;
      if( src.strides !== undefined )
      dst.strides = src.strides;
    }
    else if( src.buffer && !dst.buffer && src.scalarsPerMatrix !== undefined )
    {
      dst.buffer = self.long.longMakeUndefined( src.buffer , src.scalarsPerMatrix );
      dst.offset = 0;
      dst.strides = null;
      dst[ stridesEffectiveSymbol ] = dst.StridesFromDimensions( src.dims, !!dst.inputRowMajor );
    }
    else if( src.buffer && dst.scalarsPerMatrix !== src.scalarsPerMatrix )
    {
      dst.buffer = self.long.longMakeUndefined( src.buffer , src.scalarsPerMatrix );
      dst.offset = 0;
      dst.strides = null;
      dst[ stridesEffectiveSymbol ] = dst.StridesFromDimensions( src.dims, !!dst.inputRowMajor );
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
    // _.assert( dst._changing[ 0 ] === 0 );
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
      let extract = it.src._exportNormalized();
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

_traverseAct.iterationDefaults = Object.create( _._cloner.iterationDefaults );
_traverseAct.defaults = _.mapSupplementOwn( Object.create( _._cloner.defaults ), _traverseAct.iterationDefaults );

//

function _equalAre( it )
{

  _.assert( arguments.length === 1, 'Expects exactly three arguments' );
  _.assert( _.routineIs( it.onNumbersAreEqual ) );
  _.assert( _.lookIterationIs( it ) );

  if( _global_.debugger )
  debugger;

  it.continue = false;

  if( !( it.src2 instanceof Self ) )
  {
    it.result = false;
    return it.result;
  }

  if( it.strictTyping )
  if( it.src.buffer.constructor !== it.src2.buffer.constructor )
  {
    it.result = false;
    return it.result;
  }

  if( it.strictContainer )
  {
    if( !_.longIdentical( it.src.dims, it.src2.dims )  )
    {
      it.result = false;
      debugger;
      return it.result;
    }
  }
  else
  {
    if( it.src.scalarsPerMatrix )
    if( it.src.dims.length < it.src2.dims.length )
    {
      if( !dimsCompare( it.src.dims, it.src2.dims ) )
      return it.result;
    }
    else
    {
      if( !dimsCompare( it.src2.dims, it.src.dims ) )
      return it.result;
    }
  }

  it.result = it.src.scalarWhile( function( atom, indexNd, indexFlat )
  {
    let atom2 = it.src2.scalarGet( indexNd );
    return it.onNumbersAreEqual( atom, atom2 );
  });

  _.assert( _.boolIs( it.result ) );
  return it.result;

  /* */

  function dimsCompare( src1, src2 )
  {
    for( let i = src1.length-1 ; i >= 0 ; i-- )
    {
      if( src1[ i ] !== src2[ i ] )
      {
        it.result = false;
        return it.result;
      }
    }
    for( let i = src2.length-1 ; i >= src1.length ; i-- )
    {
      if( src2[ i ] !== 1 )
      {
        it.result = false;
        return it.result;
      }
    }
    return true;
  }

}

_.routineExtend( _equalAre, _.equaler._equal );

//

function _secondCoerce( it )
{

  if( it.strictContainer )
  return;

  if( _.longIs( it.src ) || _.vectorAdapterIs( it.src ) )
  {
    it.src = _.Matrix.FromVector( it.src );
  }

  if( _.longIs( it.src2 ) || _.vectorAdapterIs( it.src2 ) )
  {
    it.src2 = _.Matrix.FromVector( it.src2 );
  }

}

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

/**
 * Static routine ExportStructure() exports data from the source matrix {-src-} into the destination structure {-dst-}.
 *
 * @example
 * var src = _.Matrix.Make( [ 2, 2 ] );
 * var dst = {};
 * _.Matrix.ExportStructure( { src : src, dst : dst } );
 * console.log( dst );
 * // log : {
 * //   dims: [ 2, 2 ],
 * //   buffer: Float32Array [ 4, 5, 1, 2 ],
 * //   offset: 0,
 * //   strides: [ 2, 1 ]
 * // }
 *
 * @param { MapLike } o - Options map.
 * @param { Matrix } o.src - Source matrix.
 * @param { MapLike|ObjectLike|Matrix } o.dst - Destination container.
 * @param { String } o.how - Format of structure, it should have value 'object' to prevent exception.
 * @returns { MapLike|ObjectLike|Matrix } - Returns destination container with data from current matrix.
 * @throws { Error } If arguments.length is not equal to one.
 * @throws { Error } If {-o-} is not a MapLike.
 * @throws { Error } If {-o-} has extra options.
 * @throws { Error } If {-o.src-} and {-o.dst-} are instance of Matrix and have different dimensions.
 * @static
 * @function ExportStructure
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function ExportStructure( o )
{

  o = _.routineOptions( ExportStructure, arguments );

  _.assert( _.longHas( [ 'object', 'structure' ], o.how ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( o.dst === null )
  {
    if( o.how === 'object' )
    {
      o.dst = new this.Self( o.src );
      return o.dst;
    }
    else
    {
      o.dst = Object.create( null );
    }
  }

  if( o.src === o.dst )
  return o.dst;

  /* */

  let dstIsInstance = o.dst instanceof Self;

  if( dstIsInstance )
  {

    if( _.longIs( o.src ) )
    {
      o.dst.copyFromBuffer( o.src );
      return o.dst;
    }
    else if( _.vectorAdapterIs( o.src ) )
    {
      o.dst.copyFromBuffer( this._BufferFrom( o.src ) ); /* xxx Dmytro : temporary, needs analyze */
      return o.dst;
    }
    else if( _.numberIs( o.src ) )
    {
      o.dst.copyFromScalar( o.src );
      return o.dst;
    }

  }

  let srcIsInstance = o.src instanceof Self;

  _.assert( _.mapIs( o.src ) || o.src instanceof Self );

  if( !srcIsInstance )
  {
    if( Config.debug )
    _.assertMapHasOnly( o.src, this.FieldsOfInputGroups );
  }

  if( dstIsInstance )
  {
    o.dst._changeBegin();
    // copy( 'growingDimension' );

    if( srcIsInstance )
    {

      o.dst.dims = this.DimsDeduceFrom( o.src, o.dst.dims );

      if( o.src.scalarsPerMatrix !== o.dst.scalarsPerMatrix )
      {
        o.dst._.buffer = this.long.longMakeUndefined( o.src.buffer , o.src.scalarsPerMatrix );
        o.dst._.offset = 0;
        o.dst._.strides = null;
        o.dst._.occupiedRange = null;
        o.dst._.dimsEffective = null;
        o.dst._.stridesEffective = o.dst.StridesFromDimensions( o.src.dims, 0 );
      }

    }
    else
    {

      if( _global_.debugger )
      debugger;

      let buffer = o.src.buffer;
      let offset = o.src.offset;
      let strides = o.src.strides;
      let dimsWas = o.dst.dims;
      let dims = this.DimsDeduceFrom( o.src, dimsWas ? false : true );

      if( buffer )
      {

        if
        (
             o.src.dims
          || o.src.strides
          || ( o.src.inputRowMajor !== null && o.src.inputRowMajor !== undefined )
          || ( o.src.offset !== null && o.src.offset !== undefined )
        )
        {


          // _.assert( o.src.inputRowMajor !== undefined || !!o.src.dims, 'Expects either specified {- inputRowMajor -} or {- dims -} if {- buffer -} is specified' ); // yyy
          _.assert( o.src.inputRowMajor !== undefined || !!strides, 'Expects either specified {- inputRowMajor -} or {- strides -} if {- buffer -} is specified' );

          o.dst._.offset = 0;
          o.dst._.strides = null;
          o.dst._.dims = null;
          o.dst._.stridesEffective = null;
          o.dst._.dimsEffective = null;

        }

        o.dst._.occupiedRange = null;

        if( _.vectorAdapterIs( buffer ) )
        {
          if( strides )
          strides = strides.slice();
          else
          strides = self.StridesFromDimensions( dims, o.src.inputRowMajor );

          offset = offset || 0;

          offset = buffer.offset + offset*buffer.stride;
          for( let i = 0 ; i < strides.length ; i++ )
          strides[ i ] *= buffer.stride;

          buffer = buffer._vectorBuffer;
        }

      }

      set( 'buffer', buffer );
      set( 'offset', offset );
      set( 'strides', strides );

      // if( dimsWas )
      // {
      //   let dims = this.DimsDeduceFrom( o.src, false );
      //   if( dims )
      //   {
      //     o.dst.dims = dims;
      //   }
      //   else
      //   {
      //     o.dst._dimsDeduceGrowing( dimsWas );
      //   }
      // }
      // else
      // {
      //   o.dst.dims = this.DimsDeduceFrom( o.src, dimsWas );
      //   if( !o.dst.dims && o.dst.buffer )
      //   this._dimsDeduceGrowing( dimsWas );
      // }

      // if( dims )
      // {
      //   o.dst.dims = dims;
      // }
      // else
      // {
      //   // if( o.dst.buffer )
      //   // o.dst._dimsDeduceGrowing( dimsWas );
      //   if( dimsWas )
      //   o.dst.dims = dimsWas;
      // }

      if( dims )
      {
        o.dst._.dims = dims;
      }
      else if( dimsWas )
      {
        o.dst._.dims = dimsWas;
      }
      else
      {
        o.dst._dimsDeduceInitial();
      }

      if( !o.dst._.stridesEffective )
      o.dst._.stridesEffective = o.dst.StridesEffectiveFrom( o.dst.dims, o.dst.strides, o.src.inputRowMajor );

    }

    o.dst._changeEnd();
    _.assert( o.dst._changing[ 0 ] === 0 );

    if( srcIsInstance )
    {
      o.src.scalarEach( function( it ) /* xxx */
      {
        o.dst.scalarSet( it.indexNd, it.scalar );
      });
    }

  }
  else
  {

    /* xxx : implement method grow */

    // debugger;
    // copy( 'growingDimension' );
    copy( 'dims' );

    // debugger;

    if( o.bufferNormalizing )
    {
      let extract = o.src._exportNormalized();
      _.mapExtend( o.dst, extract );
    }
    else
    {
      copy( 'buffer' );
      o.dst.strides = o.src.stridesEffective || o.src.strides;
      o.dst.offset = o.src.offset || 0;
    }

  }

  return o.dst;

  function copy( key )
  {
    if( o.src[ key ] !== null && o.src[ key ] !== undefined )
    o.dst[ key ] = o.src[ key ];
  }

  function set( key, val )
  {
    if( val !== null && val !== undefined )
    o.dst._[ key ] = val;
  }

}

ExportStructure.defaults =
{
  src : null,
  dst : null,
  how : 'object',
  bufferNormalizing : 1,
}

//

/**
 * Method exportStructure() exports data from the current matrix into the destination structure {-dst-}.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 2, 2 ] );
 * var dst = {};
 * matrix.exportStructure( { dst : dst } );
 * console.log( dst );
 * // log : {
 * //   dims: [ 2, 2 ],
 * //   buffer: Float32Array [ 4, 5, 1, 2 ],
 * //   offset: 0,
 * //   strides: [ 2, 1 ]
 * // }
 *
 * @param { MapLike } o - Options map.
 * @param { MapLike|ObjectLike|Matrix } o.dst - Destination container.
 * @param { String } o.how - Format of structure, it should have value 'object' to prevent exception.
 * @returns { MapLike|ObjectLike|Matrix } - Returns destination container with data from current matrix.
 * @method exportStructure
 * @throws { Error } If arguments are not provided.
 * @throws { Error } If {-o-} is not a MapLike.
 * @throws { Error } If {-o-} has extra options.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function exportStructure( o )
{
  let self = this;

  o = _.routineOptions( exportStructure, arguments );

  o.src = self;

  return self.ExportStructure( o );
}

exportStructure.defaults =
{
  ... _.mapBut( ExportStructure.defaults, [ 'src' ] ),
}

//

/**
 * Method _exportNormalized() extracts data from the Matrix instance and saves it in new map.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
 * var extract = matrix._exportNormalized();
 * console.log( extract );
 * // log :
 * // {
 * //  buffer : [ 1, 2, 3, 4 ],
 * //  offset : 0,
 * //  strides : 1, 2,
 * // }
 *
 * @returns { Map } - Returns map with matrix data.
 * @method _exportNormalized
 * @throws { Error } If arguments are passed.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

/* xxx : extractNormalized */
function _exportNormalized()
{
  let self = this;
  let result = Object.create( null );

  _.assert( arguments.length === 0, 'Expects no arguments' );

  result.buffer = self.long.longMakeUndefined( self.buffer, self.scalarsPerMatrix );
  result.offset = 0;
  result.strides = self.StridesFromDimensions( self.dims, 0 );

  // result.inputRowMajor = 0;

  self.scalarEach( function( it ) /* qqq : use maybe method */
  {
    let i = self._FlatScalarIndexFromIndexNd( it.indexNd, result.strides );
    result.buffer[ i ] = it.scalar;
  });

  return result;
}

// //
//
// function _copy( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects exactly two arguments' );
//
//   self.ExportStructure
//   ({
//     src : src,
//     dst : self,
//     how : 'object',
//   });
//   return self;
//
//   // let it = _._cloner( self._traverseAct, { src, dst : self, /*resetting, */ technique : 'object' } );
//   // self._traverseAct( it );
//   //
//   // return it.dst;
// }

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

  self.ExportStructure
  ({
    src : src,
    dst : self,
    how : 'object',
  });

  return self;

  // let it = _._cloner( self._traverseAct, { src, dst : self, /*resetting, */ technique : 'object' } );
  // self._traverseAct( it );
  //
  // return it.dst;

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
 * @throws { Error } If arguments.length is less then one.
 * @throws { Error } If {-src-} is not a Long.
 * @method copyFromBuffer
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
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
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

  // _.assert( dst.buffer === self.buffer ); // xxx

  // xxx
  // if( dst.buffer === self.buffer )
  // dst[ bufferSymbol ] = _.longSlice( dst.buffer );

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

  _.assert( _.longIdentical( srcDims, dstDims ), '{-src-} and {-dst-} should have same dimensions' );

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
    else _.assert( 0, 'Unknown type of {-dst-}', _.strType( dst ) );

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
      dst.eSet( it.indexLogical , it.scalar );
    });
    else if( _.longIs( dst ) )
    src.scalarEach( function( it )
    {
      dst[ it.indexLogical ] = it.scalar;
    });
    else _.assert( 0, 'Unknown type of {-dst-}', _.strType( dst ) );

  }

  return odst;
}

//

/**
 * Method ExportString() converts source matrix to string.
 *
 * @example
 * var src = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
 * var got = _.Matrix.ExportString( { src : src } );
 * console.log( got );
 * // log :
 * +1, +2,
 * +3, +4,
 *
 * @param { Map } o - Options map.
 * @param { Matrix } o.src - Source matrix.
 * @param { String } o.dst - Destination string, result of conversion appends to it.
 * @param { String } o.how - Returned format, should have value 'nice' to prevent exception.
 * @param { String } o.tab - String inserted before each new line.
 * @param { String } o.dtab - String inserted before each new row.
 * @param { Number } o.precision -  Precision of scalar values.
 * @param { BoolLike } o.usingSign - Prepend sign to scalar values.
 * @returns { String } - Returns formatted string that represents matrix of scalars.
 * @throws { Error } If options map {-o-} has extra options.
 * @throws { Error } If options map {-o-} is not map like.
 * @throws { Error } If {-o.src-} is not an instance of Matrix.
 * @throws { Error } If {-o.dst-} is not a String.
 * @throws { Error } If {-o.tab-} is not a String.
 * @throws { Error } If {-o.dtab-} is not a String.
 * @function ExportString
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function ExportString( o )
{

  o = o || Object.create( null );
  _.routineOptions( ExportString, o );
  _.assert( _.longHas( [ 'nice', 'geometry' ], o.how ) );
  _.assert( o.src instanceof this.Self );
  _.assert( _.strIs( o.dst ) );
  _.assert( _.strIs( o.tab ) );
  _.assert( _.strIs( o.dtab ) );

  let tab2 = o.tab + o.dtab;
  let scalarsPerRow = o.src.scalarsPerRow;
  let scalarsPerCol = o.src.scalarsPerCol;
  let isInt;

  if( o.how === 'nice' )
  niceExport();
  else if( o.how === 'geometry' )
  geometryExport();
  else _.assert( 0 );

  return o.dst;

  /* */

  function geometryExport()
  {

    o.dst += `\n${tab2}dims : ${_.toStr( o.src.dimsEffective || o.src.dims )}`;
    o.dst += `\n${tab2}strides : ${_.toStr( o.src.stridesEffective || o.src.strides )}`;
    if( o.src.occupiedRange )
    o.dst += `\n${tab2}occupiedRange : ${_.toStr( o.src.occupiedRange )}`;
    if( o.src.buffer )
    o.dst += `\n${tab2}buffer.length : ${o.src.buffer.length}`;

  }

  /* */

  function niceExport()
  {

    isInt = true;
    o.src.scalarEach( function( it )
    {
      isInt = isInt && _.intIs( it.scalar );
    });

    if( o.src.dims.length === 2 )
    {

      matrixToStr();

    }
    else if( o.src.dims.length > 2 )
    {

      o.src.sliceEach( ( it ) =>
      {
        if( it.indexFlat > 0 )
        o.dst += `\n`;
        o.dst += `Matrix ${it.indexNd.join( ' ' )}\n`;
        matrixToStr( it.indexNd );
      });

    }
    else _.assert( 0, 'not implemented' );

  }

  /* */

  function matrixToStr( matrixIndexNd )
  {
    let r;

    for( r = 0 ; r < scalarsPerCol ; r += 1 )
    {
      rowToStr( matrixIndexNd, r );
      if( r < scalarsPerCol - 1 )
      o.dst += '\n' + o.tab;
    }

    if( o.src.dims[ 0 ] === Infinity )
    {
      o.dst += '\n';
      for( let c = 0 ; c < scalarsPerRow ; c += 1 )
      o.dst += o.infinityStr + o.scalarDelimeterStr;
    }

  }

  /* */

  function rowToStr( matrixIndexNd, r )
  {
    let row;

    o.dst += tab2;

    if( matrixIndexNd === undefined )
    row = o.src.rowGet( r );
    else
    row = o.src.rowNdGet([ r, ... matrixIndexNd ]);

    for( let c = 0 ; c < scalarsPerRow ; c += 1 )
    {
      eToStr( row.eGet( c ) );
    }

    if( o.src.dims[ 1 ] === Infinity )
    o.dst += o.infinityStr;

  }

  /* */

  function eToStr( e )
  {

    if( isInt )
    {
      if( !o.usingSign || e < 0 )
      o.dst += e.toFixed( 0 );
      else
      o.dst += '+' + e.toFixed( 0 );
    }
    else
    {
      o.dst += e.toFixed( o.precision );
    }

    o.dst += o.scalarDelimeterStr;
  }

  /* */

}

ExportString.defaults =
{
  src : null,
  dst : '',
  how : 'nice', /* [ 'nice', 'geometry', 'dims' ] */
  tab : '',
  dtab : '  ',
  scalarDelimeterStr : ' ',
  infinityStr : '...',
  precision : 3,
  usingSign : 1,
}

//

function exportString( o )
{
  let self = this;
  o = _.routineOptions( exportString, arguments );
  o.src = self;
  let result = self.ExportString( o );
  return result;
}

exportString.defaults =
{
  ... _.mapBut( ExportString.defaults, [ 'src' ] )
}

//

/**
 * Method dimsExportString() converts dimensions values to string.
 *
 * @example
 * var matrix = _.Matrix.Make( [ 3, 4 ] );
 * var got = matrix.dimsExportString( { dst : 'dims of matrix : ' } );
 * console.log( got );
 * // log : dims of matrix : 3x4
 *
 * @param { MapLike } o - Options map.
 * @param { String } o.dst - Destination string, the result of conversion appends to it.
 * @returns { String } - Returns value whether are dimensions of two matrices the same.
 * @method dimsExportString
 * @throws { Error } If {-o-} is not a MapLike.
 * @throws { Error } If {-o-} has extra options.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function dimsExportString( o )
{
  let self = this;
  o = _.routineOptions( dimsExportString, arguments );

  o.dst += self.dims[ 0 ];

  for( let i = 1 ; i < self.dims.length ; i++ )
  o.dst += `x${self.dims[ i ]}`;

  return o.dst;
}

dimsExportString.defaults =
{
  dst : '',
}

//

/**
 * Method bufferExport() copies content of the matrix to the buffer {-dst-}.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
 * var dst = [ 0, 0, 0, 0 ];
 * var got = matrix.bufferExport( dst );
 * console.log( got );
 * // log : [ 1, 2, 3, 4 ]
 * console.log( got === dst );
 * // log : true
 *
 * @param { Long } dst - Destination buffer.
 * @returns { Long } - Returns destination buffer filled by values of matrix buffer.
 * If {-dst-} is undefined, then method returns copy of matrix buffer.
 * @method bufferExport
 * @throws { Error } If arguments.length is more then one.
 * @throws { Error } If {-dst-} is not a Long.
 * @throws { Error } If number of elements in matrix is not equal to dst.length.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

/* qqq2 : good coverage is required */

function bufferExport( o )
{
  let self = this;
  let scalarsPerMatrix = self.scalarsPerMatrix;

  if( !_.mapIs( o ) )
  o = { dstBuffer : o };
  // o = { buffer : o }; /* Dmytro : field `buffer` not exists in options of routine */

  _.routineOptions( bufferExport, o );

  if( o.restriding === null )
  o.restriding = self.buffer.length >= scalarsPerMatrix*2;
  if( o.dstObject === null )
  o.dstObject = Object.create( null );

  if( o.dstBuffer )
  {

    _.assert( !o.restriding, 'not tested' );
    if( o.restriding )
    self.scalarEach( function( it )
    {
      o.dstBuffer[ self.flatScalarIndexFrom( it.indexNd ) ] = it.scalar ;
    });

  }
  else
  {
    if( o.asFloat ) /* qqq : cover please */
    {
      if( self.buffer instanceof F64x )
      {
        if( o.restriding )
        o.dstBuffer = self.long.longMakeUndefined( self.buffer, scalarsPerMatrix );
        else
        o.dstBuffer = self.long.longMake( self.buffer );
      }
      else
      {
        if( o.restriding )
        o.dstBuffer = self.long.longMakeUndefined( F32x, scalarsPerMatrix );
        else
        o.dstBuffer = self.long.longMake( F32x, self.buffer );
      }
    }
    else
    {
      if( o.restriding )
      o.dstBuffer = self.long.longMakeUndefined( self.buffer, scalarsPerMatrix );
      else
      o.dstBuffer = self.long.longMake( self.buffer );
    }
  }

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.longIs( o.dstBuffer ) );

  if( o.restriding )
  {
    _.assert
    (
      scalarsPerMatrix === o.dstBuffer.length,
      `Buffer for matrix ${self.dimsExportString()} should have ${scalarsPerMatrix} scalars, but got ${o.dstBuffer.length}`
    );
    self.scalarEach( function( it )
    {
      o.dstBuffer[ it.indexLogical ] = it.scalar;
    });
    if( o.dstObject )
    {
      o.dstObject.dims = self.dims;
      o.dstObject.strides = self.StridesFromDimensions( self.dims, false );
      o.dstObject.offset = 0;
      o.dstObject.buffer = o.dstBuffer;
    }
  }
  else
  {
    let occupiedRange = self.occupiedRange;
    _.assert
    (
         0 <= occupiedRange[ 0 ] && occupiedRange[ 0 ] < o.dstBuffer.length
      && 0 <= occupiedRange[ 1 ] && occupiedRange[ 1 ] <= o.dstBuffer.length
      , () => 'Bad buffer for such dimensions and stride', self.exportString({ how : 'geometry' })
    );
    if( o.dstObject )
    {
      o.dstObject.dims = self.dims;
      o.dstObject.strides = self.strides || self.stridesEffective;
      o.dstObject.offset = self.offset;
      o.dstObject.buffer = o.dstBuffer;
    }
  }

  if( o.dstObject )
  return o.dstObject;
  else
  return o.dstBuffer;
}

bufferExport.defaults =
{
  dstBuffer : null,
  dstObject : 0,
  restriding : 1, /* xxx : set to 0 */
  asFloat : 0,
}

//

/**
 * Method toStr() converts current matrix to string.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
 * var got = matrix.toStr();
 * console.log( got );
 * // log :
 * +1, +2,
 * +3, +4,
 *
 * @param { Map } o - Options map.
 * @param { String } o.tab - String inserted before each new line.
 * @param { String } o.dtab - String inserted before each new row.
 * @param { Number } o.precision -  Precision of scalar values.
 * @param { BoolLike } o.usingSign - Prepend sign to scalar values.
 * @returns { String } - Returns formatted string that represents matrix of scalars.
 * @method toStr
 * @throws { Error } If options map {-o-} has extra options.
 * @throws { Error } If options map {-o-} is not map like.
 * @throws { Error } If {-o.dst-} is not a String.
 * @throws { Error } If {-o.tab-} is not a String.
 * @throws { Error } If {-o.dtab-} is not a String.
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

  let o2 =
  {
    src : self,
    ... _.mapOnly( o, self.ExportString.defaults ),
  }

  return self.ExportString( o2 );
}

toStr.defaults =
{
  tab : '',
  precision : 3,
  usingSign : 1,
}

toStr.defaults.__proto__ = _.toStr.defaults;

// function toStr( o )
// {
//   let self = this;
//   let result = '';
//
//   o = o || Object.create( null );
//   _.routineOptions( toStr, o );
//
//   let l = self.dims[ 0 ];
//   let scalarsPerRow, scalarsPerCol;
//   let col, row;
//   let m, c, r, e;
//
//   let isInt = true;
//   self.scalarEach( function( it )
//   {
//     isInt = isInt && _.intIs( it.scalar );
//   });
//
//   /* */
//
//   function eToStr()
//   {
//     let e = row.eGet( c );
//
//     if( isInt )
//     {
//       if( !o.usingSign || e < 0 )
//       result += e.toFixed( 0 );
//       else
//       result += '+' + e.toFixed( 0 );
//     }
//     else
//     {
//       result += e.toFixed( o.precision );
//     }
//
//     result += ', ';
//
//   }
//
//   /* */
//
//   function rowToStr()
//   {
//
//     if( m === undefined )
//     row = self.rowGet( r );
//     else
//     row = self.rowOfMatrixGet( [ m ], r );
//
//     if( scalarsPerRow === Infinity )
//     {
//       e = 0;
//       eToStr();
//       result += '*Infinity';
//     }
//     else for( c = 0 ; c < scalarsPerRow ; c += 1 )
//     eToStr();
//
//   }
//
//   /* */
//
//   function matrixToStr( m )
//   {
//
//     scalarsPerRow = self.scalarsPerRow;
//     scalarsPerCol = self.scalarsPerCol;
//
//     if( scalarsPerCol === Infinity )
//     {
//       r = 0;
//       rowToStr( 0 );
//       result += ' **Infinity';
//     }
//     else for( r = 0 ; r < scalarsPerCol ; r += 1 )
//     {
//       rowToStr( r );
//       if( r < scalarsPerCol - 1 )
//       result += '\n' + o.tab;
//     }
//
//   }
//
//   /* */
//
//   if( self.dims.length === 2 )
//   {
//
//     matrixToStr();
//
//   }
//   else if( self.dims.length === 3 )
//   {
//
//     for( m = 0 ; m < l ; m += 1 )
//     {
//       result += 'Slice ' + m + ' :\n';
//       matrixToStr( m );
//     }
//
//   }
//   else _.assert( 0, 'not implemented' );
//
//   return result;
// }
//
// toStr.defaults =
// {
//   tab : '',
//   precision : 3,
//   usingSign : 1,
// }
//
// toStr.defaults.__proto__ = _.toStr.defaults;

//

/**
 * Method toLong() converts current matrix to a Long.
 *
 * @example
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
 * var got = matrix.toLong();
 * console.log( got );
 * // log : Float32Array [ 1, 3, 2, 4 ]
 *
 * @returns { Long } - Returns Long filled by scalars of current matrix.
 * @method toLong
 * @throws { Error } If method calls by not instance of Matrix.
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function toLong( o )
{
  let self = this;
  o = _.routineOptions( toLong, o );
  let result = self.bufferExport({ restriding : o.restriding });
  return result;
}

toLong.defaults =
{
  restriding : 1,
}

// --
// size in bytes
// --

function _sizeGet()
{
  let result = this.sizeOfScalar*this.scalarsPerMatrix;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfSliceGet()
{
  let result = this.sizeOfScalar*this.scalarsPerSlice;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfElementGet()
{
  let result = this.sizeOfScalar*this.scalarsPerElement;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfElementStrideGet()
{
  let result = this.sizeOfScalar*this.strideOfElement;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfColGet()
{
  let result = this.sizeOfScalar*this.scalarsPerCol;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfColStrideGet()
{
  let result = this.sizeOfScalar*this.strideOfCol;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfRowGet()
{
  let result = this.sizeOfScalar*this.scalarsPerRow;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfRowStrideGet()
{
  let result = this.sizeOfScalar*this.strideOfRow;
  _.assert( result >= 0 );
  return result;
}

//

function _sizeOfScalarGet()
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
  let result = self.dimsEffective[ 0 ];
  _.assert( result >= 0 );
  return result;
}

//

function _scalarsPerRowGet()
{
  let self = this;
  let result = self.dimsEffective[ 1 ];
  _.assert( result >= 0 );
  return result;
}

//

function _nrowGet()
{
  let self = this;
  let result = self.dimsEffective[ 0 ];
  _.assert( result >= 0 );
  return result;
}

//

function _ncolGet()
{
  let self = this;
  let result = self.dimsEffective[ 1 ];
  _.assert( result >= 0 );
  return result;
}

//

function _scalarsPerSliceGet()
{
  let self = this;
  return self[ scalarsPerSliceSymbol ];
}

//

function _scalarsPerMatrixGet()
{
  let self = this;
  return self[ scalarsPerMatrixSymbol ];
}

//

function _slicesPerMatrixGet()
{
  let self = this;
  return self[ slicesPerMatrixSymbol ];
}

//

function _nsliceGet()
{
  let self = this;
  return self[ slicesPerMatrixSymbol ];
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

  for( let d = dims.length-1 ; d >= 0 ; d-- )
  {
    _.assert( dims[ d ] >= 0 );
    if( dims[ d ] !== Infinity )
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
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
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

  let result = self._FlatScalarIndexFromIndexNd( indexNd, self.stridesEffective );

  return result + self.offset;
}

//

function _FlatScalarIndexFromIndexNd( indexNd, strides )
{
  let result = 0;

  if( Config.debug )
  {
    _.assert( arguments.length === 2, 'Expects exactly two arguments' );
    _.assert( _.arrayIs( indexNd ) );
    _.assert( _.arrayIs( strides ) );
    _.assert( indexNd.length >= strides.length );
    for( let i = strides.length ; i < indexNd.length ; i++ )
    _.assert( indexNd[ i ] === 0 );
  }

  for( let i = 0 ; i < strides.length ; i++ )
  {
    result += indexNd[ i ]*strides[ i ];
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

  _.assert( _.longIs( src ) || src === null );

  if( _.longIs( src ) )
  src = _.longSlice( src );

  self[ stridesSymbol ] = src;

  self._sizeChanged();

}

//

function _strideOfElementGet()
{
  return this.stridesEffective[ this.stridesEffective.length-1 ];
}

//

function _strideOfColGet()
{
  return this.stridesEffective[ 1 ];
}

//

function _strideInColGet()
{
  return this.stridesEffective[ 0 ];
}

//

function _strideOfRowGet()
{
  return this.stridesEffective[ 0 ];
}

//

function _strideInRowGet()
{
  return this.stridesEffective[ 1 ];
}

//

function StridesEffectiveFrom( dims, strides, inputRowMajor )
{
  let result;

  _.assert( !!dims );
  _.assert( !!strides || _.boolLike( inputRowMajor ), 'If field {- strides -} is not spefified explicitly then field {- inputRowMajor -} should be specified explicitly.' ); /* yyy */
  _.assert( dims[ 0 ] >= 0 );
  _.assert( dims[ dims.length-1 ] >= 0 );
  _.assert( arguments.length === 2 || arguments.length === 3 );

  if( strides )
  {
    result = strides.slice();
  }
  else
  {
    result = this.StridesFromDimensions( dims, inputRowMajor );
  }

  result = this.StridesEffectiveAdjust( result, dims );

  return result;
}

//

/**
 * Static routine StridesFromDimensions() calculates strides for each dimension taking into account rowMajor value.
 *
 * @example
 * var strides = _.Matrix.StridesFromDimensions( [ 2, 2 ], true );
 * console.log( strides );
 * // log : [ 2, 1 ]
 *
 * @param { Array } dims - Dimensions of a matrix.
 * @param { BoolLike } rowMajor - Options defines rowMajor of the matrix.
 * @returns { Array } - Returns strides for each dimension of the matrix.
 * @throws { Error } If arguments.length is not equal to two.
 * @throws { Error } If {-dims-} is not an Array.
 * @throws { Error } If {-rowMajor-} is not BoolLike.
 * @throws { Error } If elements of {-dims-} is negative number.
 * @static
 * @function StridesFromDimensions
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function StridesFromDimensions( dims, rowMajor )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.arrayIs( dims ), 'Expects dims' );
  _.assert( _.boolLike( rowMajor ) );
  _.assert( dims[ 0 ] >= 0 );
  _.assert( dims[ dims.length-1 ] >= 0 );

  let strides = dims.slice();

  if( rowMajor )
  {
    let ex = strides[ 1 ];
    strides[ 1 ] = strides[ 0 ];
    strides[ 0 ] = ex;
  }

  strides.splice( strides.length-1, 1 );
  strides.unshift( 1 );

  let current = strides[ 0 ];
  for( let i = 1 ; i < strides.length ; i++ )
  {
    current = strides[ i ] = current * normalize( strides[ i ] );
  }

  if( rowMajor )
  {
    let ex = strides[ 1 ];
    strides[ 1 ] = strides[ 0 ];
    strides[ 0 ] = ex;
  }

  // strides = this.StridesEffectiveAdjust( strides, dims );

  if( dims[ 0 ] === Infinity )
  strides[ 0 ] = 0;
  if( dims[ 1 ] === Infinity )
  strides[ 1 ] = 0;

  return strides;

  /* */

  function strideGet( i )
  {

    if( rowMajor )
    if( i === 0 )
    i = 1;
    else if( i === 1 )
    i = 0;

    let result = stride[ i ]

    _.assert( result >= 0 );

    return result;
  }

  /* */

  function normalize( stride )
  {
    if( stride === Infinity )
    return 1;
    return stride;
  }

  /* */

}

//

/**
 * Static routine StridesEffectiveAdjust() analyzes dimensions in argument {-dims-} and normalize strides of a matrix.
 * If the last dimensions of 3D matrix or higher is 1 or Infinity, then strides removes removes.
 *
 * @example
 * var got = _.Matrix.StridesEffectiveAdjust( [ 2, 1, 3, 2 ], [ 2, 2, 1, Infinity ] );
 * console.log( got );
 * // log : [ 2, 1 ]
 *
 * @param { Long } strides - Strides of a matrix.
 * @param { Long } dims - Dimensions of a matrix.
 * @returns { Long } - Returns effective dimensions of a matrix.
 * @throws { Error } If {-strides-} has not valid type.
 * @throws { Error } If {-dims-} has not valid type.
 * @static
 * @function StridesEffectiveAdjust
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function StridesEffectiveAdjust( strides, dims )
{

  _.assert( !!strides );
  _.assert( !!dims );
  _.assert( arguments.length === 2 );
  _.assert( strides.length === dims.length );

  if( dims[ 0 ] === Infinity )
  strides[ 0 ] = 0;
  if( dims[ 1 ] === Infinity )
  strides[ 1 ] = 0;

  if( dims.length > 2 )
  if( dims[ dims.length-1 ] === 1 || dims[ dims.length-1 ] === Infinity )
  {
    strides.splice( strides.length-1, 1 );
    for( let i = strides.length-1 ; i >= 2 ; i-- )
    if( dims[ i ] === 1 || dims[ i ] === Infinity )
    strides.splice( i, 1 );
    else
    break;
  }

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

function bufferSet( src )
{
  let self = this;

  if( self[ bufferSymbol ] === src )
  return;

  if( _.numberIs( src ) )
  src = this.long.longMake([ src ]);

  _.assert( _.longIs( src ) || src === null );

  self._.buffer = src;

  if( !self._changing[ 0 ] )
  {
    self._.offset = 0;
    self._.stridesEffective = null;
    // self._.dims = self._dimsDeduceGrowing( self._.dims ); // yyy
  }

  self._sizeChanged();
}

//

function offsetSet( src )
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
  _.assert
  (
    self.scalarsPerMatrix === src.length,
    `Matrix ${self.dimsExportString()} should have ${self.scalarsPerMatrix} scalars, but got ${src.length}`
  );

  let inputRowMajor = 1;
  let strides = self.StridesFromDimensions( self.dimsEffective, inputRowMajor );
  self.scalarEach( function( it )
  {
    let indexFlat = self._FlatScalarIndexFromIndexNd( it.indexNd, strides );
    self.scalarSet( it.indexNd, src[ indexFlat ] );
  });

  self._changeEnd();
  return self;
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

function bufferNormalize() /* qqq : optimize */
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
    inputRowMajor : 0,
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

  self._changing[ 0 ] += 1;

  /* strides */

  if( _.numberIs( self.strides ) )
  {
    debugger;
    let strides = [ 1, 1 ];
    strides[ strides.length-1 ] = self.strides;
    self.strides = self.StridesRoll( strides );
  }

  /* dims */

  _.assert( self.dims === null || _.longIs( self.dims ) );

  if( !self.dims )
  {
    // self._dimsDeduceGrowing(); // yyy
    self._dimsDeduceInitial();
  }

  _.assert( _.arrayIs( self.dims ) );

  if( self.buffer === null )
  {
    let lengthFlat = self.ScalarsPerMatrixForDimensions( self.dims );
    self.buffer = self.long.longMake( lengthFlat );
  }

  self[ dimsEffectiveSymbol ] = self.DimsEffectiveFrom( self.dims ); /* xxx : replace */
  self[ lengthSymbol ] = self.LengthFrom( self.dims );

  self[ scalarsPerMatrixSymbol ] = _.avector.reduceToProduct( self.dimsEffective );
  self[ scalarsPerSliceSymbol ] = self.dimsEffective[ 0 ] * self.dimsEffective[ 1 ];
  self[ slicesPerMatrixSymbol ] = self.scalarsPerMatrix / ( self.dimsEffective[ 0 ] * self.dimsEffective[ 1 ] );

  let lastDim = self.dims[ self.dims.length-1 ];
  if( lastDim === Infinity || lastDim === 0 )
  self[ scalarsPerElementSymbol ] = _.avector.reduceToProduct( self.DimsNormalize( self.dims.slice( 0, self.dims.length-1 ) ) );
  else
  self[ scalarsPerElementSymbol ] = self.scalarsPerMatrix / lastDim;

  /* strides */

  if( !self.stridesEffective )
  {
    self[ stridesEffectiveSymbol ] = self.StridesEffectiveFrom( self.dims, self.strides, 0 );
  }

  _.assert( self.stridesEffective.length >= 2 );

  /* buffer region */

  let occupiedRange = self.OccupiedRangeFrom( self.dims, self.stridesEffective, self.offset );
  self._.occupiedRange = occupiedRange;
  if( self.scalarsPerMatrix )
  if( self.buffer.length )
  {
    _.assert
    (
         0 <= occupiedRange[ 0 ] && occupiedRange[ 0 ] < self.buffer.length
      && 0 <= occupiedRange[ 1 ] && occupiedRange[ 1 ] <= self.buffer.length
      , () => 'Bad buffer for such dimensions and stride', self.exportString({ how : 'geometry' })
    );
  }

  /* done */

  _.entityFreeze( self.dimsEffective );
  _.entityFreeze( self.dims );
  _.entityFreeze( self.stridesEffective );

  self._changing[ 0 ] -= 1;
}

//

function _adjustVerify()
{
  let self = this;

  _.assert( _.longIs( self.strides ) || self.strides === null, 'Bad strides' );
  _.assert( _.numberIs( self.offset ) && self.offset >= 0, 'Matrix expects defined non-negative offset' );

}

//

function _adjustValidate()
{
  let self = this;

  if( !Config.debug )
  return

  _.assert( _.arrayIs( self.dims ) );
  _.assert( self.length >= 0 );
  _.assert( self.scalarsPerElement >= 0 );

  _.assert( _.longIs( self.buffer ), 'Matrix needs buffer' );
  _.assert( _.longIs( self.strides ) || self.strides === null );
  _.assert( self.offset >= 0, 'Matrix needs proper offset' );

  _.assert( _.longIs( self.stridesEffective ) );
  _.assert( _.numbersAreInt( self.stridesEffective ) );
  _.assert( self.stridesEffective.length >= 2 );

  _.assert( _.numbersAreInt( self.dims ) );
  _.assert( _.numbersArePositive( self.dims ) );

  _.assert( _.intIs( self.length ) );
  _.assert( self.length >= 0 );
  _.assert( self.dims[ self.dims.length-1 ] === self.length || self.dims[ self.dims.length-1 ] === Infinity );

  for( let d = 0 ; d < self.dims.length-1 ; d++ )
  _.assert( self.dims[ d ] >= 0 );

  if( self.scalarsPerMatrix > 0 && _.numberIsFinite( self.length ) )
  for( let d = 0 ; d < self.dimsEffective.length ; d++ )
  _.assert
  (
    self.offset + ( self.dimsEffective[ d ]-1 )*self.stridesEffective[ d ] <= self.buffer.length
    , () => 'Out of bound' + self.exportString({ how : 'geometry' })  /* xxx */
    // , `\n  offset : ${self.offset}`
    // , `\n  dims : ${_.toStr( self.dimsEffective )}`
    // , `\n  strides : ${_.toStr( self.stridesEffective )}`
  );

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

  }
  else
  {
    self[ dimsSymbol ] = null;
  }

  _.assert( self[ dimsSymbol ] === null || _.numbersAreInt( self[ dimsSymbol ] ) );

  self[ stridesEffectiveSymbol ] = null;

  self._sizeChanged();

  return src;
}

//

function _dimsEffectiveGet()
{
  let self = this;
  return self[ dimsEffectiveSymbol ];
}

//

/**
 * Static routine DimsEffectiveFrom() analyzes dimensions in argument {-dims-} and normalize it.
 * If the last dimensions of 3D matrix or higher is 1 or Infinity, it removes.
 *
 * @example
 * var got = _.Matrix.DimsEffectiveFrom( [ 2, 1, 1, Infinity ] );
 * console.log( got );
 * // log : [ 2, 1 ]
 *
 * @param { Long } dims - Dimensions of a matrix.
 * @returns { Long } - Returns effective dimensions of a matrix.
 * @throws { Error } If {-dims-} has not valid type.
 * @static
 * @function DimsEffectiveFrom
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function DimsEffectiveFrom( dims )
{

  for( let i1 = 0 ; i1 < dims.length ; i1++ )
  if( dims[ i1 ] === Infinity )
  {
    let dimsEffective = dims.slice();
    dimsEffective[ i1 ] = 1;
    for( let i2 = i1+1 ; i2 < dimsEffective.length ; i2++ )
    if( dimsEffective[ i2 ] === Infinity )
    dimsEffective[ i2 ] = 1;
    dims = dimsEffective;
    break;
  }

  if( dims.length > 2 )
  if( dims[ dims.length-1 ] === 1 )
  {
    let dimsEffective = dims.slice( 0, dims.length-1 );
    for( let i = dimsEffective.length-1 ; i >= 2 ; i-- )
    if( dimsEffective[ i ] === 1 )
    dimsEffective.splice( i, 1 );
    else
    break;
    dims = dimsEffective;
  }

  return dims;
}

//

function DimsNormalize( dims )
{

  for( let i1 = 0 ; i1 < dims.length ; i1++ )
  if( dims[ i1 ] === Infinity )
  {
    let dimsEffective = dims.slice();
    dimsEffective[ i1 ] = 1;
    for( let i2 = i1+1 ; i2 < dimsEffective.length ; i2++ )
    if( dimsEffective[ i2 ] === Infinity )
    dimsEffective[ i2 ] = 1;
    dims = dimsEffective;
    break;
  }

  return dims;
}

// //
//
// function _dimsDeduceGrowing( dimsWas )
// {
//   let self = this;
//
//   _.assert( arguments.length === 0 || arguments.length === 1 );
//
//   if( dimsWas )
//   {
//     _.assert( _.longIs( self.buffer ) );
//     _.assert( self.offset >= 0 );
//
//     let dims = dimsWas.slice();
//     dims[ self.growingDimension ] = 1;
//     let ape = _.avector.reduceToProduct( dims );
//     let l = ( self.buffer.length - self.offset ) / ape;
//     dims[ self.growingDimension ] = l;
//     self[ dimsSymbol ] = dims;
//
//     _.assert( l >= 0 );
//     _.assert( _.intIs( l ) );
//
//     return dims;
//   }
//   else if( self.strides )
//   {
//     _.assert( 0, 'Cant deduce dimensions from only strides' );
//   }
//   else
//   {
//     _.assert( _.longIs( self.buffer ), 'Expects buffer' );
//     if( self.buffer.length - self.offset > 0 )
//     {
//       self[ dimsSymbol ] = [ self.buffer.length - self.offset, 1 ];
//       if( !self.stridesEffective )
//       self[ stridesEffectiveSymbol ] = [ 1, self.buffer.length - self.offset ];
//     }
//     else
//     {
//       self[ dimsSymbol ] = [ 1, 0 ];
//       if( !self.stridesEffective )
//       self[ stridesEffectiveSymbol ] = [ 1, 1 ];
//     }
//     return self[ dimsSymbol ];
//   }
//
// }
//

function _dimsDeduceInitial()
{
  let self = this;

  _.assert( arguments.length === 0 ); debugger; /* xxx */

  // if( dimsWas )
  // {
  //   _.assert( _.longIs( self.buffer ) );
  //   _.assert( self.offset >= 0 );
  //
  //   let dims = dimsWas.slice();
  //   dims[ self.growingDimension ] = 1;
  //   let ape = _.avector.reduceToProduct( dims );
  //   let l = ( self.buffer.length - self.offset ) / ape;
  //   dims[ self.growingDimension ] = l;
  //   self[ dimsSymbol ] = dims;
  //
  //   _.assert( l >= 0 );
  //   _.assert( _.intIs( l ) );
  //
  //   return dims;
  // }
  // else if( self.strides )
  // {
  //   _.assert( 0, 'Cant deduce dimensions from only strides' );
  // }
  // else
  // {
    _.assert( _.longIs( self.buffer ), 'Expects buffer' );
    if( self.buffer.length - self.offset > 0 )
    {
      self._.dims = [ self.buffer.length - self.offset, 1 ];
      if( !self.stridesEffective )
      self._.stridesEffective = [ 1, self.buffer.length - self.offset ];
    }
    else
    {
      self._.dims = [ 1, 0 ];
      if( !self.stridesEffective )
      self._.stridesEffective = [ 1, 1 ];
    }
    return self[ dimsSymbol ];
  // }

}

//

function DimsDeduceFrom( src, fallbackDims )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  if( fallbackDims === undefined )
  fallbackDims = true;

  if( src.dims )
  {
    _.assert( _.intIs( src.dims[ 0 ] ) );
    _.assert( _.intIs( src.dims[ 1 ] ) );
    return src.dims;
  }

  let dim0, dim1;
  let offset = src.offset || 0;

  if( src.scalarsPerCol !== undefined && src.scalarsPerCol !== null )
  {
    dim0 = src.scalarsPerCol;
  }
  else if( src.scalarsPerElement !== undefined && src.scalarsPerElement !== null )
  {
    dim0 = src.scalarsPerElement;
  }
  else if( src.ncol !== undefined && src.ncol !== null )
  {
    dim0 = src.ncol;
  }

  if( src.scalarsPerRow !== undefined && src.scalarsPerRow !== null )
  {
    dim1 = src.scalarsPerRow; debugger;
  }
  else if( src.nrow !== undefined && src.nrow !== null )
  {
    dim1 = src.nrow;
  }

/* example :

                ____        ____        _____
  buffer : [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
  offset : 1
  dims : [ 3, 2 ]
  strides : [ 4, 1 ]
  m :
  [
    1 2
    5 6
    9 10
  ]

*/

  // if( _global_.debugger )
  // debugger;

  if( src.buffer )
  {

    if( fallbackDims )
    if( dim0 === undefined && dim1 === undefined && src.strides )
    {
      if( src.strides[ 0 ] > src.strides[ 1 ] )
      {
        dim0 = Math.floor( ( src.buffer.length - offset ) / src.strides[ 0 ] );
      }
      else
      {
        dim1 = Math.floor( ( src.buffer.length - offset ) / src.strides[ 1 ] );
      }
    }

    if( dim0 === undefined && dim1 !== undefined )
    {
      let stride;
      let l = src.buffer.length - offset;
      if( src.strides && src.strides[ 0 ] >= src.strides[ 1 ] )
      {
        stride = src.strides[ 0 ];
        if( dim1 !== undefined && dim1 < src.strides[ 0 ] )
        l += src.strides[ 0 ] - dim1;
      }
      else
      {
        stride = dim1;
      }
      dim0 = Math.floor( l / stride );
    }

    if( dim1 === undefined && dim0 !== undefined )
    {
      let stride;
      let l = src.buffer.length - offset;
      if( src.strides && src.strides[ 1 ] >= src.strides[ 0 ] )
      {
        stride = src.strides[ 1 ];
        if( dim0 !== undefined && dim0 < src.strides[ 1 ] )
        l += src.strides[ 1 ] - dim0;
      }
      else
      {
        stride = dim0;
      }
      dim1 = Math.floor( l / stride );
    }

  }

  if( dim0 === undefined || dim1 === undefined )
  {
    _.assert( dim0 === undefined );
    _.assert( dim1 === undefined );

    if( !fallbackDims )
    return;

    if( _.arrayIs( fallbackDims ) )
    {
      dim0 = fallbackDims[ 0 ];
      dim1 = fallbackDims[ 1 ];
    }
    else if( src.buffer && src.inputRowMajor )
    {
      dim0 = src.buffer.length;
      dim1 = 1;
    }
    else
    {
      dim0 = 1;
      dim1 = src.buffer.length;
    }

  }

  let result = [ dim0, dim1 ];

  _.assert( _.intIs( result[ 0 ] ), 'Cant deduce {- dims -} of the matrix' );
  _.assert( _.intIs( result[ 1 ] ), 'Cant deduce {- dims -} of the matrix' );

  return result;
}

//

/**
 * Static routine LengthFrom() returns length of last dimension of a matrix.
 * If dimension has value Infinity, then it replaces to 1.
 *
 * @example
 * var got = _.Matrix.LengthFrom( [ 2, 2, Infinity ] );
 * console.log( got );
 * // log : 1
 *
 * @param { Long } dims - Dimensions of a matrix.
 * @returns { Long } - Returns length of last dimension of a matrix.
 * @throws { Error } If {-dims-} has not valid type.
 * @static
 * @function LengthFrom
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function LengthFrom( dims )
{
  let result = dims[ dims.length-1 ];
  if( result === Infinity )
  result = 1;
  return result;
}

//

/**
 * Static routine OccupiedRangeFrom() calculates the part of buffer that occupied matrix.
 *
 * @example
 * var got = _.Matrix.OccupiedRangeFrom( [ 2, 2 ], [ 3, 1 ], 5 );
 * console.log( got );
 * // log : [ 5, 10 ]
 *
 * @param { Long } dims - Dimensions of a matrix.
 * @param { Long } strides - Strides of a matrix.
 * @param { Number } offset - Offset of a matrix.
 * @returns { Long } - Returns length of last dimension of a matrix.
 * @throws { Error } If {-dims-} has not valid type.
 * @throws { Error } If {-strides-} has not valid type.
 * @static
 * @function OccupiedRangeFrom
 * @class Matrix
 * @namespace wTools
 * @module Tools/math/Matrix
 */

function OccupiedRangeFrom( dims, strides, offset )
{

  _.assert( arguments.length === 3 );

  let occupiedRange = [ 0, 0 ];

  let extreme = [ 0, 0 ];

  for( let s = 0 ; s < strides.length ; s++ )
  {
    if( dims[ s ] === Infinity )
    continue;

    let delta = dims[ s ] > 0 ? strides[ s ]*( dims[ s ]-1 ) : 0;

    if( delta >= 0 )
    extreme[ 1 ] = extreme[ 1 ] + delta;
    else
    extreme[ 0 ] = extreme[ 0 ] + delta;

  }

  occupiedRange[ 0 ] += extreme[ 0 ];
  occupiedRange[ 1 ] += extreme[ 1 ];
  occupiedRange[ 0 ] += offset;
  occupiedRange[ 1 ] += offset;
  occupiedRange[ 1 ] += 1;

  return occupiedRange;
}

//

/**
 * Static routine ShapesAreSame() compares dimensions of two matrices {-ins1-} and {-ins-}.
 *
 * @example
 * var matrix1 = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
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
 * var matrix = _.Matrix.MakeSquare
 * ([
 *   1, 2,
 *   3, 4
 * ]);
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

  if( src instanceof Self )
  src = src.dims;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayIs( src ) );

  return _.longIdentical( self.dimsEffective, src ); /* qqq : add test routine to explain */
}

// --
// relations
// --

let bufferSymbol = Symbol.for( 'buffer' );
let offsetSymbol = Symbol.for( 'offset' );
let dimsSymbol = Symbol.for( 'dims' );
let dimsEffectiveSymbol = Symbol.for( 'dimsEffective' );
let stridesSymbol = Symbol.for( 'strides' );
let stridesEffectiveSymbol = Symbol.for( 'stridesEffective' );
let lengthSymbol = Symbol.for( 'length' );
let scalarsPerMatrixSymbol = Symbol.for( 'scalarsPerMatrix' );
let scalarsPerSliceSymbol = Symbol.for( 'scalarsPerSlice' );
let slicesPerMatrixSymbol = Symbol.for( 'slicesPerMatrix' );
let scalarsPerElementSymbol = Symbol.for( 'scalarsPerElement' );
let occupiedRangeSymbol = Symbol.for( 'occupiedRange' );

//

let Composes =
{

  dims : null,
  // growingDimension : 1,

}

//

let Aggregates =
{
}

//

let Associates =
{
  buffer : null,
}

//

let Restricts =
{

  // _dimsWas : null,
  _changing : [ 1 ], // xxx : remove

}

//

let Medials =
{

  strides : null,
  offset : 0,
  scalarsPerElement : null,
  scalarsPerCol : null,
  scalarsPerRow : null,
  ncol : null,
  nrow : null,
  inputRowMajor : null,

}

//

let Statics =
{

  /* */

  Is,
  ExportStructure,
  ExportString,
  CopyTo,

  ScalarsPerMatrixForDimensions,
  NrowOf, /* qqq : cover routine NrowOf. should work for any vector, matrix and scalar */
  NcolOf, /* qqq : cover routine NcolOf. should work for any vector, matrix and scalar */
  DimsOf, /* qqq : cover routine DimsOf. should work for any vector, matrix and scalar */
  _FlatScalarIndexFromIndexNd,

  StridesFromDimensions,
  StridesEffectiveAdjust,
  StridesRoll,
  DimsEffectiveFrom,
  DimsNormalize,
  DimsDeduceFrom,
  LengthFrom,
  OccupiedRangeFrom,
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
  colLength : 'colLength',
  rowLength : 'rowLength',
  _generator : '_generator',
  usingOptimizedAccessors : 'usingOptimizedAccessors',
  dimensionsDesired : 'dimensionsDesired',
  array : 'array',
  inputRowMajor : 'inputRowMajor',
  inputTransposing : 'inputTransposing',
  breadth : 'breadth',
  _dimsWas : '_dimsWas',
  ncols : 'ncols',
  nrows : 'nrows',
  growingDimension : 'growingDimension',

}

/*
xxx : implement fast vad iterator
xxx : optimize scalar iteration
*/

//

let write = { put : _.accessor.putter.symbol, addingMethods : 1 };
let readPut = { put : _.accessor.putter.symbol, addingMethods : 1, set : 0 };
let readOnly = { put : 0, set : 0, addingMethods : 1 };

let Accessors =
{

  /* etc */

  _ : { get : _.accessor.getter.toValue, set : 0, put : 0, strict : 0 }, /* xxx */
  buffer : write,
  offset : write,

  /* vectors */

  strides : write,
  dims : write,
  dimsEffective : { get : _dimsEffectiveGet, set : false },
  occupiedRange : readPut, /* cached */
  stridesEffective : readPut, /* cached */

  /* size in bytes */

  size : readOnly,
  sizeOfSlice : readOnly,
  sizeOfElement : readOnly,
  sizeOfElementStride : readOnly,
  sizeOfCol : readOnly,
  sizeOfColStride : readOnly,
  sizeOfRow : readOnly,
  sizeOfRowStride : readOnly,
  sizeOfScalar : readOnly,

  /* length in scalars */

  scalarsPerElement : readPut, /* cached */
  scalarsPerCol : readOnly,
  scalarsPerRow : readOnly,
  ncol : readOnly,
  nrow : readOnly,
  scalarsPerSlice : readPut, /* qqq : cover */
  scalarsPerMatrix : readOnly,

  strideOfElement : readOnly,
  strideOfCol : readOnly,
  strideInCol : readOnly,
  strideOfRow : readOnly,
  strideInRow : readOnly,

  /* other metrics */

  slicesPerMatrix : readPut, /* qqq : cover */
  nslice : readPut, /* qqq : cover */
  length : readPut, /* cached */

}

// --
// declare
// --

let Extension =
{

  // inter

  init,
  Is,
  _traverseAct, /* zzz : deprecate */
  _equalAre,
  _secondCoerce,

  _longGet,

  // import / export

  ExportStructure,
  exportStructure,
  _exportNormalized,
  copy,

  copyFromScalar,
  copyFromBuffer,
  clone,

  CopyTo,
  ExportString,
  exportString,
  dimsExportString,
  bufferExport, /* qqq : cover */

  toStr,
  toLong,

  // size in bytes

  _sizeGet,
  _sizeOfSliceGet,

  _sizeOfElementGet,
  _sizeOfElementStrideGet,

  _sizeOfColGet,
  _sizeOfColStrideGet,

  _sizeOfRowGet,
  _sizeOfRowStrideGet,

  _sizeOfScalarGet,

  // length in scalars

  _scalarsPerElementGet, /* cached */
  _scalarsPerColGet,
  _scalarsPerRowGet,
  _nrowGet,
  _ncolGet,
  _scalarsPerSliceGet,
  _scalarsPerMatrixGet,
  _slicesPerMatrixGet,
  _nsliceGet,

  ScalarsPerMatrixForDimensions,
  NrowOf,
  NcolOf,
  DimsOf,

  flatScalarIndexFrom,
  _FlatScalarIndexFromIndexNd,

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

  StridesEffectiveFrom,
  StridesFromDimensions,
  StridesEffectiveAdjust,
  StridesRoll,

  // buffer

  bufferSet, /* cached */
  offsetSet, /* cached */

  _bufferAssign,

  bufferNormalize,

  // buffer : _.define.accessor({ put : _.accessor.putter.symbol, addingMethods : 1 }),

  // reshaping

  _changeBegin,
  _changeEnd,

  _sizeChanged,

  _adjust,
  _adjustAct,
  _adjustVerify,
  _adjustValidate,

  _dimsSet, /* cached */
  _dimsEffectiveGet, /* cached */
  DimsEffectiveFrom,
  DimsNormalize,
  // _dimsDeduceGrowing,
  _dimsDeduceInitial,
  DimsDeduceFrom,
  LengthFrom,
  OccupiedRangeFrom,

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

Object.defineProperty( Self, 'accuracySqrt',
{
  get : function() { return this.vectorAdapter.accuracySqrt },
});

Object.defineProperty( Self.prototype, 'accuracy',
{
  get : function() { return this.vectorAdapter.accuracy },
});

Object.defineProperty( Self.prototype, 'accuracySqr',
{
  get : function() { return this.vectorAdapter.accuracySqr },
});

Object.defineProperty( Self.prototype, 'accuracySqrt',
{
  get : function() { return this.vectorAdapter.accuracySqrt },
});

_.accessor.readOnly( Self, { long : { get : _longGet, set : false } } );
_.accessor.readOnly( Self.prototype, { long : { get : _longGet, set : false } } );

_.Matrix = Self;

_.assert( !!_.vectorAdapter );
_.assert( !!_.vectorAdapter.long );

_.assert( _.objectIs( _.withDefaultLong ) );
_.assert( _.objectIs( _.withDefaultLong.Fx ) );

_.assert( Self.prototype.vectorAdapter.long === Self.vectorAdapter.long );
_.assert( Self.long === Self.vectorAdapter.long );
_.assert( Self.prototype.long === Self.vectorAdapter.long );
_.assert( Self.long === _.vectorAdapter.long );
_.assert( _.routineIs( Self.prototype.bufferGet ) );
_.assert( _.routineIs( Self.prototype.bufferSet ) );
_.assert( _.routineIs( Self.prototype.bufferPut ) );

})();
