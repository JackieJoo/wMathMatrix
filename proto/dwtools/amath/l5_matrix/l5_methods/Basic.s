(function _Basic_s_() {

'use strict';

let _ = _global_.wTools;
let abs = Math.abs;
let min = Math.min;
let max = Math.max;
let pow = Math.pow;
let pi = Math.PI;
let sin = Math.sin;
let cos = Math.cos;
let sqrt = Math.sqrt;
let sqr = _.math.sqr;

let Parent = null;
let Self = _.Matrix;

_.assert( _.objectIs( _.vectorAdapter ) );
_.assert( _.routineIs( Self ), 'wMatrix is not defined, please include wMatrix.s first' );

// --
// borrow
// --

  /**
   * The method is a temporary cache for matrix,
   * writes the matrix to a specific object depending on the index.
   * Depends on index and key that is generated by bufferConstruction name and dimensions of matrix.
   *
   * @param { Matrix } Matrix - instance of matrix.
   * @param { Array } dims - size of provided matrix.
   * @param { Number } index - number of method, which will be called.
   *
   * @example
   * var buffer = new I32x( 6 )
   *
   * var m = new _.Matrix
   * ({
   *   buffer,
   *   dims : [ 3, 3 ],
   *   inputTransposing : 1,
   * });
   *
   * var got = matrix._tempBorrow( m, [ 4, 4 ], 1 );
   * logger.log( got );
   * // log
   * new I32x
   * [
   *  0, 0, 0, 0,
   *  0, 0, 0, 0,
   *  0, 0, 0, 0,
   * ];
   *
   * @returns { Matrix } - Returns instance of Matrix based on provided arguments.
   * @method _tempBorrow
   * @throws { Error } If (arguments.length) is not 3.
   * @throws { Error } If {-src-} is not instance of Matrix.
   * @throws { Error } If {-dims-} is not array.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function _tempBorrow( src, dims, index )
{
  let bufferConstructor;

  _.assert( arguments.length === 3, 'Expects exactly three arguments' );
  _.assert( src instanceof Self || src === null );
  _.assert( _.arrayIs( dims ) || dims instanceof Self || dims === null );

  if( !src )
  {

    // debugger;
    // bufferConstructor = this.array.ArrayType;
    // bufferConstructor = this.longDescriptor;
    bufferConstructor = this.long.longDescriptor.type;
    if( !dims )
    dims = src;

  }
  else
  {

    if( src.buffer )
    bufferConstructor = src.buffer.constructor;

    if( !dims )
    if( src.dims )
    dims = src.dims.slice();

  }

  if( dims instanceof Self )
  dims = dims.dims;

  _.assert( _.routineIs( bufferConstructor ) );
  _.assert( _.arrayIs( dims ) );
  _.assert( index < 3 );

  let key = bufferConstructor.name + '_' + dims.join( 'x' );

  if( this._tempMatrices[ index ][ key ] )
  return this._tempMatrices[ index ][ key ];

  let result = this._tempMatrices[ index ][ key ] = new Self
  ({
    dims,
    buffer : new bufferConstructor( this.AtomsPerMatrixForDimensions( dims ) ),
    inputTransposing : 0,
  });

  return result;
}

//

function tempBorrow1( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 0 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 0 );
  else
  return Self._tempBorrow( null, src , 0 );

}

//

function tempBorrow2( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 1 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 1 );
  else
  return Self._tempBorrow( null, src , 1 );

}

//

function tempBorrow3( src )
{

  _.assert( arguments.length <= 1 );
  if( src === undefined )
  src = this;

  if( this instanceof Self )
  return Self._tempBorrow( this, src , 2 );
  else if( src instanceof Self )
  return Self._tempBorrow( src, src , 2 );
  else
  return Self._tempBorrow( null, src , 2 );

}

// --
// mul
// --

  /**
   * The method matrix.pow is short-cut matrixPow returns an instance of Matrix with exponentiation values provided matrix,
   * takes destination matrix from context.
   *
   * @param { Number|String } - exponent - number or string.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +3, +2, +3,
   *   +4, +0, +2
   *   +0, +0, +6,
   * ]);
   *
   * var got = matrix.pow( 2 );
   * logger.log( got );
   * // log
   * +17, +6, +31,
   * +12, +8, +24,
   * +0, +0, +36,
   *
   * @returns { Matrix } - Returns instance of Matrix.
   * @method pow
   * @throws { Error } If provided source is not instance of Matrix.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function matrixPow( exponent )
{

  _.assert( _.instanceIs( this ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  let t = this.tempBorrow( this );

  // self.mul(  );

}

//

function mul_static( dst, srcs )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.arrayIs( srcs ) );
  _.assert( srcs.length >= 2 );

  /* adjust dst */

  if( dst === null )
  {
    let dims = [ this.NrowOf( srcs[ srcs.length-2 ] ) , this.NcolOf( srcs[ srcs.length-1 ] ) ];
    dst = this.makeSimilar( srcs[ srcs.length-1 ] , dims );
  }

  /* adjust srcs */

  srcs = srcs.slice();
  let dstClone = null;

  let odst = dst;
  dst = this.from( dst );

  for( let s = 0 ; s < srcs.length ; s++ )
  {

    srcs[ s ] = this.from( srcs[ s ] );

    if( dst === srcs[ s ] || dst.buffer === srcs[ s ].buffer )
    {
      if( dstClone === null )
      {
        dstClone = dst.tempBorrow1();
        dstClone.copy( dst );
      }
      srcs[ s ] = dstClone;
    }

    _.assert( dst.buffer !== srcs[ s ].buffer );

  }

  /* */

  dst = this.mul2Matrices( dst , srcs[ 0 ] , srcs[ 1 ] );

  /* */

  if( srcs.length > 2 )
  {

    let dst2 = null;
    let dst3 = dst;
    for( let s = 2 ; s < srcs.length ; s++ )
    {
      let src = srcs[ s ];
      if( s % 2 === 0 )
      {
        dst2 = dst.tempBorrow2([ dst3.dims[ 0 ], src.dims[ 1 ] ]);
        this.mul2Matrices( dst2 , dst3 , src );
      }
      else
      {
        dst3 = dst.tempBorrow3([ dst2.dims[ 0 ], src.dims[ 1 ] ]);
        this.mul2Matrices( dst3 , dst2 , src );
      }
    }

    if( srcs.length % 2 === 0 )
    this.CopyTo( odst, dst3 );
    else
    this.CopyTo( odst, dst2 );

  }
  else
  {
    this.CopyTo( odst, dst );
  }

  return odst;
}

//
  /**
   * The method matrix.mull() returns multiplies values of provided matrix {-srcs-}.
   *
   * @param { Matrix } srcs - provided matrices.
   *
   * @example
   * var buffer = new I32x
   * ([
   *  +2, +2, -2,
   *  -2, -3, +4,
   *  +4, +3, -2,
   * ]);
   *
   * var m = new _.Matrix
   * ({
   *   buffer,
   *   dims : [ 3, 3 ],
   *   inputTransposing : 1,
   * });
   *
   * var got = matrix.mul( m, [ m, m ] );
   * console.log( got.buffer );
   * // log
   * new I32x
   * [
   *  -8, -8, +8,
   *  +18, +17, -16,
   *  -6, -7, +8,
   * ];
   *
   *
   * @returns { Matrix } - Returns new Matrix instance with multiplies values of buffer.
   * @method mul
   * @throws { Error } If (arguments.length) is more than 1.
   * @throws { Error } If {-srcs-} is not array.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function mul( srcs )
{
  let dst = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayIs( srcs ) );

  return dst.Self.mul( dst, srcs );
}

//

function Mul2Matrices( dst, src1, src2 )
{

  src1 = this.fromForReading( src1 );
  src2 = this.fromForReading( src2 );

  if( dst === null )
  {
    dst = this.make([ src1.dims[ 0 ], src2.dims[ 1 ] ]);
  }

  _.assert( arguments.length === 3, 'Expects exactly three arguments' );
  _.assert( src1.dims.length === 2 );
  _.assert( src2.dims.length === 2 );
  _.assert( dst instanceof Self );
  _.assert( src1 instanceof Self );
  _.assert( src2 instanceof Self );
  _.assert( dst !== src1 );
  _.assert( dst !== src2 );
  _.assert( src1.dims[ 1 ] === src2.dims[ 0 ], 'Expects src1.dims[ 1 ] === src2.dims[ 0 ]' );
  _.assert( src1.dims[ 0 ] === dst.dims[ 0 ] );
  _.assert( src2.dims[ 1 ] === dst.dims[ 1 ] );

  let nrow = dst.nrow;
  let ncol = dst.ncol;

  for( let r = 0 ; r < nrow ; r++ )
  for( let c = 0 ; c < ncol ; c++ )
  {
    let row = src1.rowVectorGet( r );
    let col = src2.colVectorGet( c );
    let dot = this.vectorAdapter.dot( row, col );
    dst.atomSet( [ r, c ], dot );
  }

  return dst;
}

//

function mul2Matrices( src1, src2 )
{
  let dst = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return dst.Self.mul2Matrices( dst, src1, src2 );
}

//
  /**
   * The method matrix.mulLeft() multiplies values of provided matrices and returns left matrix with these values.
   *
   * @param { Matrix } - src - an instance of Matrix.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5
   *   +0, +0, +6,
   * ]);
   *
   * var src = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +4, +1, +2,
   *   +0, +0, +1,
   * ]);
   *
   * var got = matrix.mulLeft( src );
   * logger.log( matrix );
   * // log
   *   +9, +4, +10,
   *   +16, +4, +13
   *   +0, +0, +6,
   *
   * logger.log( src );
   * // log
   *   +1, +2, +3,
   *   +4, +1, +2,
   *   +0, +0, +1,
   *
   * @returns { Matrix } - Returns an instance of Matrix.
   * @method mulLeft
   * @throws { Error } If (arguments.length) is more than 1.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function mulLeft( src )
{
  let dst = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  // debugger;

  dst.mul([ dst, src ])

  return dst;
}

//
  /**
   * The method matrix.mulRight() multiplies values of provided matrices and returns right matrix with these values.
   *
   * @param { Matrix } - src - an instance of Matrix.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5
   *   +0, +0, +6,
   * ]);
   *
   * var src = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +4, +1, +2,
   *   +0, +0, +1,
   * ]);
   *
   * var got = matrix.mulRight( src );
   * logger.log( matrix );
   * // log
   *   +1, +2, +3,
   *   +0, +4, +5
   *   +0, +0, +6,
   *
   * logger.log( src );
   * // log
   *   +9, +4, +10,
   *   +16, +4, +13
   *   +0, +0, +6,
   *
   * @returns { Matrix } - Returns an instance of Matrix.
   * @method mulRight
   * @throws { Error } If (arguments.length) is more than 1.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function mulRight( src )
{
  let dst = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  // debugger;

  dst.mul([ src, dst ]);
  // dst.mul2Matrices( src, dst );

  return dst;
}

// //
//
// function _mulMatrix( src )
// {
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( src.breadth.length === 1 );
//
//   let self = this;
//   let atomsPerRow = self.atomsPerRow;
//   let atomsPerCol = src.atomsPerCol;
//   let code = src.buffer.constructor.name + '_' + atomsPerRow + 'x' + atomsPerCol;
//
//   debugger;
//   if( !self._tempMatrices[ code ] )
//   self._tempMatrices[ code ] = self.Self.make([ atomsPerCol, atomsPerRow ]);
//   let dst = self._tempMatrices[ code ]
//
//   debugger;
//   dst.mul2Matrices( dst, self, src );
//   debugger;
//
//   self.copy( dst );
//
//   return self;
// }
//
// //
//
// function mulAssigning( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( self.breadth.length === 1 );
//
//   let result = self._mulMatrix( src );
//
//   return result;
// }
//
// //
//
// function mulCopying( src )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( src.dims.length === 2 );
//   _.assert( self.dims.length === 2 );
//
//   let result = Self.make( src.dims );
//   result.mul2Matrices( result, self, src );
//
//   return result;
// }

// --
// partial accessors
// --

  /**
   * The method matrix.zero() returns instance of Matrix, values filled with zeros,
   * takes source from context.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5
   *   +0, +0, +6,
   * ]);
   *
   * var got = matrix.zero();
   * logger.log( got );
   * // log
   *   +0, +0, +0,
   *   +0, +0, +0
   *   +0, +0, +0,
   *
   * @returns { Matrix } - Returns new instance of Matrix.
   * @method zero
   * @throws { Error } If (arguments.length) exist.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function zero()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self.atomEach( ( it ) => self.atomSet( it.indexNd, 0 ) );

  return self;
}

//
  /**
   * The method matrix.identity() returns an instance of an identity matrix, based on dimension provided matrix( takes from context ).
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +3, +2, +3,
   *   +4, +0, +2
   *   +0, +0, +6,
   * ]);
   *
   * var got = matrix.identity();
   * logger.log( got );
   * // log
   *   +1, +0, +0,
   *   +0, +1, +0,
   *   +0, +0, +1,
   *
   * @returns { Matrix } - Returns instance of Matrix.
   * @method identity
   * @throws { Error } If arguments exist.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function identify()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );

  self.atomEach( ( it ) => it.indexNd[ 0 ] === it.indexNd[ 1 ] ? self.atomSet( it.indexNd, 1 ) : self.atomSet( it.indexNd, 0 ) );

  return self;
}

//
  /**
   * The method matrix.diagonalSet() returns an instance of Matrix with diagonal values {-src-} matrix,
   * takes destination matrix from context.
   *
   * @param { Matrix } - src - an instance of Matrix.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +3, +2, +3,
   *   +4, +0, +2
   *   +0, +0, +6,
   * ]);
   *
   * var src = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +4, +5, +4
   *   +3, +2, +1,
   * ]);
   *
   * var got = matrix.diagonalSet( src );
   * logger.log( got );
   * // log
   * +1, +2, +3,
   * +4, +5, +2,
   * +0, +0, +1,
   *
   * @returns { Matrix } - Returns instance of Matrix.
   * @method diagonalSet
   * @throws { Error } If (arguments.length) is more the one.
   * @throws { Error } If (src.length) is not same length destination matrix.
   * @throws { Error } If matrix dimension length is more than two.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function diagonalSet( src )
{
  let self = this;
  let length = Math.min( self.atomsPerCol, self.atomsPerRow );

  if( src instanceof Self )
  src = src.diagonalVectorGet();

  src = self.vectorAdapter.fromMaybeNumber( src, length );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.dims.length === 2 );
  _.assert( src.length === length );

  for( let i = 0 ; i < length ; i += 1 )
  {
    self.atomSet( [ i, i ], src.eGet( i ) );
  }

  return self;
}

//
  /**
   * The method matrix.diagonalVectorGet() returns an instance of VectorAdapter filled by values,
   * takes source from context.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +3, +2, +3,
   *   +4, +0, +2
   *   +0, +0, +6,
   * ]);
   *
   * var got = matrix.diagonalVectorGet();
   * logger.log( got );
   * // log 3.000 0.000 6.000
   *
   * @returns { VectorAdapter } - Returns instance of VectorAdapter.
   * @method diagonalVectorGet
   * @throws { Error } If (arguments.length) exist.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function diagonalVectorGet()
{
  let self = this;
  let length = Math.min( self.atomsPerCol, self.atomsPerRow );
  let strides = self._stridesEffective;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( self.dims.length === 2 );

  let result = self.vectorAdapter.fromLongLrangeAndStride( self.buffer, self.offset, length, strides[ 0 ] + strides[ 1 ] );

  return result;
}

//
  /**
   * The method matrix.triangleLowerSet() returns the instance of Matrix based on a source (takes from context)
   * with values of the lower left triangle {-src-} matrix.
   *
   * @param { Matrix } - src - an instance of Matrix.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5,
   *   +0, +0, +6,
   * ]);
   *
   * var src = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +0, +0,
   *   +1, +1, +0,
   *   +1, +1, +1,
   * ]);
   *
   * var got = matrix.triangleLowerSet( src );
   * logger.log( got );
   * // log
   *   +1, +2, +3,
   *   +1, +4, +5,
   *   +1, +1, +6,
   *
   * @returns { Matrix } - Returns an instance of Matrix.
   * @method triangleLowerSet
   * @throws { Error } If (arguments.length) is more than one.
   * @throws { Error } If matrix dimension length is more than two.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function triangleLowerSet( src )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = self.ncol;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 0 ] >= self.dims[ 0 ] );
    _.assert( src.dims[ 1 ] >= min( self.dims[ 0 ]-1, self.dims[ 1 ] ) );

    for( let r = 1 ; r < nrow ; r++ )
    {
      let cl = min( r, ncol );
      for( let c = 0 ; c < cl ; c++ )
      self.atomSet( [ r, c ], src.atomGet([ r, c ]) );
    }

  }
  else
  {

    for( let r = 1 ; r < nrow ; r++ )
    {
      let cl = min( r, ncol );
      for( let c = 0 ; c < cl ; c++ )
      self.atomSet( [ r, c ], src );
    }

  }

  return self;
}

//
  /**
   * The method matrix.triangleUpperSet() returns the instance of Matrix based on a source (takes from context)
   * with values of the upper right triangle {-src-} matrix.
   *
   * @param { Matrix } - src - an instance of Matrix.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5,
   *   +0, +0, +6,
   * ]);
   *
   * var src = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +0, +0,
   *   +1, +1, +0,
   *   +1, +1, +1,
   * ]);
   *
   * var got = matrix.triangleUpperSet( src );
   * logger.log( got );
   * // log
   *  +1, +0, +0,
   *  +0, +4, +0,
   *  +0, +0, +6,
   *
   * @returns { Matrix } - Returns an instance of Matrix.
   * @method triangleUpperSet
   * @throws { Error } If (arguments.length) is more than one.
   * @throws { Error } If matrix dimension length is more than two.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function triangleUpperSet( src )
{
  let self = this;
  let nrow = self.nrow;
  let ncol = self.ncol;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.dims.length === 2 );

  _.assert( _.numberIs( src ) || src instanceof Self );

  if( src instanceof Self )
  {

    _.assert( src.dims[ 1 ] >= self.dims[ 1 ] );
    _.assert( src.dims[ 0 ] >= min( self.dims[ 1 ]-1, self.dims[ 0 ] ) );

    for( let c = 1 ; c < ncol ; c++ )
    {
      let cl = min( c, nrow );
      for( let r = 0 ; r < cl ; r++ )
      self.atomSet( [ r, c ], src.atomGet([ r, c ]) );
    }

  }
  else
  {

    for( let c = 1 ; c < ncol ; c++ )
    {
      let cl = min( c, nrow );
      for( let r = 0 ; r < cl ; r++ )
      self.atomSet( [ r, c ], src );
    }

  }

  return self;
}

// --
// transformer
// --

// function applyMatrixToVector( dstVector )
// {
//   let self = this;
//
//   _.assert( 0, 'deprecated' );
//
//   self.vectorAdapter.matrixApplyTo( dstVector, self );
//
//   return self;
// }

//

// function matrixHomogenousApply( dstVector )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1 )
//   _.assert( 0, 'not tested' );
//
//   self.vectorAdapter.matrixHomogenousApply( dstVector, self );
//
//   return self;
// }

function matrixApplyTo( dstVector )
{
  let self = this;

  if( self.hasShape([ 3, 3 ]) )
  {

    let dstVectorv = self.vectorAdapter.from( dstVector );
    let x = dstVectorv.eGet( 0 );
    let y = dstVectorv.eGet( 1 );
    let z = dstVectorv.eGet( 2 );

    let s00 = self.atomGet([ 0, 0 ]), s10 = self.atomGet([ 1, 0 ]), s20 = self.atomGet([ 2, 0 ]);
    let s01 = self.atomGet([ 0, 1 ]), s11 = self.atomGet([ 1, 1 ]), s21 = self.atomGet([ 2, 1 ]);
    let s02 = self.atomGet([ 0, 2 ]), s12 = self.atomGet([ 1, 2 ]), s22 = self.atomGet([ 2, 2 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y + s02 * z );
    dstVectorv.eSet( 1 , s10 * x + s11 * y + s12 * z );
    dstVectorv.eSet( 2 , s20 * x + s21 * y + s22 * z );

    return dstVector;
  }
  else if( self.hasShape([ 2, 2 ]) )
  {

    let dstVectorv = self.vectorAdapter.from( dstVector );
    let x = dstVectorv.eGet( 0 );
    let y = dstVectorv.eGet( 1 );

    let s00 = self.atomGet([ 0, 0 ]), s10 = self.atomGet([ 1, 0 ]);
    let s01 = self.atomGet([ 0, 1 ]), s11 = self.atomGet([ 1, 1 ]);

    dstVectorv.eSet( 0 , s00 * x + s01 * y );
    dstVectorv.eSet( 1 , s10 * x + s11 * y );

    return dstVector;
  }

  return Self.mul( dstVector, [ self, dstVector ] );
}

//
  /**
   * The method matrix.matrixHomogenousApply() apply the homogenous matrix to provided vector {-dstVector-}, returns the instance of VectorAdapter,
   * takes source from context.
   *
   * @param { VectorAdapter } - dstVector - destination instance of VectorAdapter.
   *
   * @example
   * var matrix = _.Matrix.make([ 3, 3 ]).copy
   * ([
   *   4, 0, 1,
   *   0, 5, 2,
   *   0, 0, 1,
   * ]);
   *
   * var dstVector = [ 0, 0 ];
   *
   * var got = matrix.matrixHomogenousApply( dstVector );
   * logger.log
   * // log
   *  [ 1, 2 ]
   *
   * @returns { VectorAdapter } - Returns the instance of VectorAdapter.
   * @method matrixHomogenousApply
   * @throws { Error } If (arguments.length) is more the one.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function matrixHomogenousApply( dstVector )
{
  let self = this;
  let _dstVector = self.vectorAdapter.from( dstVector );
  let dstLength = dstVector.length;
  let ncol = self.ncol;
  let nrow = self.nrow;
  let result = new Array( nrow );

  _.assert( arguments.length === 1 );
  _.assert( dstLength === ncol-1 );

  result[ dstLength ] = 0;
  for( let i = 0 ; i < nrow ; i += 1 )
  {
    let row = self.rowVectorGet( i );

    result[ i ] = 0;
    for( let j = 0 ; j < dstLength ; j++ )
    result[ i ] += row.eGet( j ) * _dstVector.eGet( j );
    result[ i ] += row.eGet( dstLength );

  }

  for( let j = 0 ; j < dstLength ; j++ )
  _dstVector.eSet( j, result[ j ] / result[ dstLength ] );

  return dstVector;
}

//

function matrixDirectionsApply( dstVector )
{
  let self = this;
  let dstLength = dstVector.length;
  let ncol = self.ncol;
  let nrow = self.nrow;

  _.assert( arguments.length === 1 );
  _.assert( dstLength === ncol-1 );

  debugger;

  Self.mul( v, [ self.submatrix([ [ 0, v.length ], [ 0, v.length ] ]), v ] );
  self.vectorAdapter.normalize( v );

  return dstVector;
}
//
  /**
   * The method matrix.positionGet() Returns offset or position specified by the matrix, takes source from context.
   *
   * @example
   * var buffer = new I32x
   * ([
   *   +2, +2, +2,
   *   +2, +3, +4,
   *   +4, +3, -2,
   * ]);
   *
   * var matrix = new _.Matrix
   * ({
   *  buffer,
   *  dims : [ 3, 3 ],
   *  inputTransposing : 1,
   * });
   *
   * var got = matrix.positionGet();
   * logger.log
   * // log 2.000 4.000
   *
   * @returns { VectorAdapter } - Returns offset or position specified by the matrix.
   * @method positionGet
   * @throws { Error } If argument exist.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function positionGet()
{
  let self = this;
  let l = self.length;
  let loe = self.atomsPerElement;
  let result = self.colVectorGet( l-1 );

  _.assert( arguments.length === 0, 'Expects no arguments' );

  // debugger;
  result = self.vectorAdapter.fromLongLrange( result, 0, loe-1 );

  //let result = self.elementsInRangeGet([ (l-1)*loe, l*loe ]);
  //let result = self.vectorAdapter.fromLongLrange( this.buffer, 12, 3 );

  return result;
}

//
  /**
   * The method matrix.positionSet() sets and return position {-src-} specified by the matrix.
   *
   * @param { Long } - src - an instance of Long.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +6, +4, +6,
   *   +8, +0, +4
   *   +0, +0, +12,
   * ]);
   *
   * var src = [ 4, 4 ];
   *
   * var got = matrix.positionSet( src );
   * logger.log
   * // log 4.000, 4.000
   *
   * @returns { VectorAdapter } - Returns position specified by the matrix.
   * @method scaleGet
   * @throws { Error } If {-src-} and destination matrix length is not same.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function positionSet( src )
{
  let self = this;
  src = self.vectorAdapter.fromLong( src );
  let dst = this.positionGet();

  _.assert( src.length === dst.length );

  self.vectorAdapter.assign( dst, src );
  return dst;
}

//
  /**
   * The method matrix.scaleMaxGet() returns maximum value of scale specified by the matrix.
   *
   * @param { VectorAdapter } - dst - an instance of VectorAdapter.
   *
   * @example
   * var buffer = new I32x
   * ([
   *   +2, +2, +2,
   *   +2, +3, +4,
   *   +4, +3, -2,
   * ]);
   *
   * var matrix = new _.Matrix
   * ({
       buffer,
       dims : [ 3, 3 ],
       inputTransposing : 1,
   * });
   *
   * var dst = _.vectorAdapter.fromLong( [ 0, 0 ] );
   *
   * var got = matrix.scaleMaxGet( dst )
   * logger.log
   * // log
   *   4.000 4.000
   *  +6, +4, +4,
   *  +8, +0, +4,
   *  +0, +0, +12,
   *   3.605551275463989
   *
   * @returns { Matrix } - Returns maximum value of scale specified by the matrix.
   * @method scaleMaxGet
   * @throws { Error } If (arguments.length) is more than one.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function scaleMaxGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.reduceToMaxAbs( scale ).value;
  return result;
}

//

function scaleMeanGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.reduceToMean( scale );
  return result;
}

//

function scaleMagGet( dst )
{
  let self = this;
  let scale = self.scaleGet( dst );
  let result = _.avector.mag( scale );
  return result;
}

//
  /**
   * The method matrix.scaleGet() returns scale specified by the matrix.
   *
   * @param { Array|VectorAdapter } - dst - array or the instance of VectorAdapter.
   *
   * @example
   * var buffer = new I32x
   * ([
   *   +2, +2, +2,
   *   +2, +3, +4,
   *   +4, +3, -2,
   * ]);
   *
   * var matrix = new _.Matrix
   * ({
   *   buffer,
   *   dims : [ 3, 3 ],
   *   inputTransposing : 1,
   * });
   *
   * var dst = _.vectorAdapter.fromLong( [ 0, 0 ] );
   *
   * var got = matrix.scaleGet( dst );
   * logger.log
   * // log
   *  4.000 4.000
   *  +6, +4, +4,
   *  +8, +0, +4,
   *  +0, +0, +12,
   *  2.828, 3.606
   *
   * @returns { Matrix } - Returns scale specified by the matrix.
   * @method scaleGet
   * @throws { Error } If (arguments.length) is more than one.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

  function scaleGet( dst )
{
  let self = this;
  let l = self.length-1;
  let loe = self.atomsPerElement;

  if( dst )
  {
    if( _.arrayIs( dst ) )
    dst.length = self.length-1;
  }

  if( dst )
  l = dst.length;
  else
  dst = self.vectorAdapter.from( self.long.longMakeZeroed( self.length-1 ) );

  let dstv = self.vectorAdapter.from( dst );

  _.assert( arguments.length === 0 || arguments.length === 1 );

  for( let i = 0 ; i < l ; i += 1 )
  dstv.eSet( i , self.vectorAdapter.mag( self.vectorAdapter.fromLongLrange( this.buffer, loe*i, loe-1 ) ) );

  return dst;
}

//
  /**
   * The method matrix.scaleSet() returns scaled instance of Matrix, takes source from context.
   *
   * @param { Array|VectorAdapter } - dst - array or the instance of VectorAdapter.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   3, 2, 3,
   *   4, 0, 2,
   *   0, 0, 6,
   * ]);
   *
   * var src = [ 2 ];
   *
   * var got = matrix.scaleSet( src );
   * logger.log
   * // log
   *  +6, +4, +6,
   *  +8, +0, +4
   *  +0, +0, +12,
   *
   * @returns { Matrix } - Returns scaled instance of Matrix.
   * @method scaleSet
   * @throws { Error } If (arguments.length) is more than one.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function scaleSet( src )
{
  let self = this;
  src = self.vectorAdapter.fromLong( src );
  let l = self.length;
  let loe = self.atomsPerElement;
  let cur = this.scaleGet();

  _.assert( src.length === l-1 );

  for( let i = 0 ; i < l-1 ; i += 1 )
  self.vectorAdapter.mul( self.eGet( i ), src.eGet( i ) / cur[ i ] );

  let lastElement = self.eGet( l-1 );
  self.vectorAdapter.mul( lastElement, 1 / lastElement.eGet( loe-1 ) );

}

//

function scaleAroundSet( scale, center )
{
  let self = this;
  scale = self.vectorAdapter.fromLong( scale );
  let l = self.length;
  let loe = self.atomsPerElement;
  let cur = this.scaleGet();

  _.assert( scale.length === l-1 );

  for( let i = 0 ; i < l-1 ; i += 1 )
  self.vectorAdapter.mul( self.eGet( i ), scale.eGet( i ) / cur[ i ] );

  let lastElement = self.eGet( l-1 );
  self.vectorAdapter.mul( lastElement, 1 / lastElement.eGet( loe-1 ) );

  /* */

  debugger;
  center = self.vectorAdapter.fromLong( center );
  let pos = self.vectorAdapter.slice( scale );
  pos = self.vectorAdapter.fromLong( pos );
  self.vectorAdapter.mul( pos, -1 );
  self.vectorAdapter.add( pos, 1 );
  self.vectorAdapter.mul( pos, center );
  // self.vectorAdapter.mulScalar( pos, -1 );
  // self.vectorAdapter.addScalar( pos, 1 );
  // self.vectorAdapter.mulVectors( pos, center );

  self.positionSet( pos );

}

//

function scaleApply( src )
{
  let self = this;
  src = self.vectorAdapter.fromLong( src );
  let ape = self.atomsPerElement;
  let l = self.length;

  for( let i = 0 ; i < ape ; i += 1 )
  {
    let c = self.rowVectorGet( i );
    c = self.vectorAdapter.fromLongLrange( c, 0, l-1 );
    self.vectorAdapter.mul( c, src );
    // self.vectorAdapter.mulVectors( c, src );
  }

}

// --
// reducer
// --

function closest( insElement )
{
  let self = this;
  insElement = self.vectorAdapter.fromLong( insElement );
  let result =
  {
    index : null,
    distance : +Infinity,
  }

  _.assert( arguments.length === 1, 'Expects single argument' );

  for( let i = 0 ; i < self.length ; i += 1 )
  {

    let d = self.vectorAdapter.distanceSqr( insElement, self.eGet( i ) );
    if( d < result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function furthest( insElement )
{
  let self = this;
  insElement = self.vectorAdapter.fromLong( insElement );
  let result =
  {
    index : null,
    distance : -Infinity,
  }

  _.assert( arguments.length === 1, 'Expects single argument' );

  for( let i = 0 ; i < self.length ; i += 1 )
  {

    let d = self.vectorAdapter.distanceSqr( insElement, self.eGet( i ) );
    if( d > result.distance )
    {
      result.distance = d;
      result.index = i;
    }

  }

  result.distance = sqrt( result.distance );

  return result;
}

//

function elementMean()
{
  let self = this;

  let result = self.elementAdd();

  self.vectorAdapter.div( result, self.length );

  return result;
}

//
  /**
   * The method matrix.minmaxColWise() compares columns values of matrix and returns min and max buffer instance with these values,
   * takes source from context.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5
   *   +0, +0, +6,
   * ]);
   *
   * var got = matrix.minmaxColWise();
   * console.log( got );
   * // log
   * {
   *   min: Float32Array [ 0, 0, 3 ],
   *   max: Float32Array [ 1, 4, 6 ]
   * }
   *
   * @returns { TypedArrays } - Returns two instances of F32x buffers.
   * @method minmaxColWise
   * @throws { Error } If (arguments.length) exist.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function minmaxColWise()
{
  let self = this;

  let minmax = self.distributionRangeSummaryValueColWise();
  let result = Object.create( null );

  result.min = self.long.longMakeUndefined( self.buffer, minmax.length );
  result.max = self.long.longMakeUndefined( self.buffer, minmax.length );

  for( let i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//
  /**
   * The method matrix.minmaxRowWise() compares rows values of matrix and returns min and max buffer instance with these values,
   * takes source from context.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5
   *   +0, +0, +6,
   * ]);
   *
   * var got = matrix.minmaxRowWise();
   * console.log( got );
   * // log
   * {
   *   min: Float32Array [ 1, 0, 0 ],
   *   max: Float32Array [ 3, 5, 6 ]
   * }
   *
   * @returns { TypedArrays } - Returns two instances of F32x buffers.
   * @method minmaxRowWise
   * @throws { Error } If (arguments.length) exist.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function minmaxRowWise()
{
  let self = this;

  let minmax = self.distributionRangeSummaryValueRowWise();
  let result = Object.create( null );

  result.min = self.long.longMakeUndefined( self.buffer, minmax.length );
  result.max = self.long.longMakeUndefined( self.buffer, minmax.length );

  for( let i = 0 ; i < minmax.length ; i += 1 )
  {
    result.min[ i ] = minmax[ i ][ 0 ];
    result.max[ i ] = minmax[ i ][ 1 ];
  }

  return result;
}

//
  /**
   * This method returns a determinant value of the provided matrix,
   * takes source from context.
   *
   * @example
   * var matrix = _.Matrix.make( [ 3, 3 ] ).copy
   * ([
   *   +1, +2, +3,
   *   +0, +4, +5
   *   +0, +0, +6,
   * ]);
   *
   * var got = matrix.determinant();
   * logger.log( got );
   * // log 24
   *
   * @returns { Number } - Returns a determinant value of the provided matrix.
   * @method determinant
   * @throws { Error } If (arguments.length) exist.
   * @memberof module:Tools/math/Matrix.wMatrix#
   */

function determinant()
{
  let self = this;
  let l = self.length;

  if( l === 0 )
  return 0;

  let iterations = _.math.factorial( l );
  let result = 0;

  _.assert( l === self.atomsPerElement );

  /* */

  let sign = 1;
  let index = [];
  for( let i = 0 ; i < l ; i += 1 )
  index[ i ] = i;

  /* */

  function add()
  {
    let r = 1;
    for( let i = 0 ; i < l ; i += 1 )
    r *= self.atomGet([ index[ i ], i ]);
    r *= sign;
    // console.log( index );
    // console.log( r );
    result += r;
    return r;
  }

  /* */

  function swap( a, b )
  {
    let v = index[ a ];
    index[ a ] = index[ b ];
    index[ b ] = v;
    sign *= -1;
  }

  /* */

  let i = 0;
  while( i < iterations )
  {

    for( let s = 0 ; s < l-1 ; s++ )
    {
      let r = add();
      //console.log( 'add', i, index, r );
      swap( s, l-1 );
      i += 1;
    }

  }

  /* */

  // 00
  // 01
  //
  // 012
  // 021
  // 102
  // 120
  // 201
  // 210

  // console.log( 'determinant', result );

  return result;
}

// --
// relations
// --

let Statics = /* qqq : split static routines. ask how */
{

  /* borrow */

  _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1,
  tempBorrow2,
  tempBorrow3,

  /* mul */

  mul : mul_static,
  mul2Matrices : Mul2Matrices,

  /* var */

  _tempMatrices : [ Object.create( null ) , Object.create( null ) , Object.create( null ) ],

}

/*
map
filter
reduce
zip
*/

// --
// declare
// --

let Extension =
{

  // borrow

  _tempBorrow,
  tempBorrow : tempBorrow1,
  tempBorrow1,
  tempBorrow2,
  tempBorrow3,

  // mul

  pow : matrixPow,
  mul,
  mul2Matrices,
  mulLeft,
  mulRight,

  // partial accessors

  zero,
  identify,
  diagonalSet,
  diagonalVectorGet,
  triangleLowerSet,
  triangleUpperSet,

  // transformer

  matrixApplyTo,
  matrixHomogenousApply,
  matrixDirectionsApply,

  positionGet,
  positionSet,
  scaleMaxGet,
  scaleMeanGet,
  scaleMagGet,
  scaleGet,
  scaleSet,
  scaleAroundSet,
  scaleApply,

  // reducer

  closest,
  furthest,

  elementMean,

  minmaxColWise,
  minmaxRowWise,

  determinant,

  //

  Statics,

}

_.classExtend( Self, Extension );
_.assert( Self.mul2Matrices === Mul2Matrices );
_.assert( Self.prototype.mul2Matrices === mul2Matrices );

})();
