(function _Svd_s_() {

'use strict';

let _ = _global_.wTools;
let abs = Math.abs; /* xxx */
let min = Math.min;
let max = Math.max;
let pow = Math.pow;
let pi = Math.PI;
let sin = Math.sin;
let cos = Math.cos;
let sqrt = Math.sqrt;
let sqr = _.math.sqr;
let longSlice = Array.prototype.slice;

let Parent = null;
let Self = _.Matrix;

_.assert( _.objectIs( _.vectorAdapter ) );
_.assert( _.routineIs( Self ), 'wMatrix is not defined, please include wMatrix.s first' );

// --
//
// --

/**
  * Split a M matrix into a Q and a R matrices, where M = Q*R, R is upper triangular
  * and the values of its diagonal are the eigenvalues of M, and Q is orthogonal and its columns are
  * the eigenvectors of M. Returns the eigenvalues of M. Matrix stays unchanged.
  *
  * @example
  * // returns self.vectorAdapter.from( [ 4, -2, -2 ] );
  * var matrix =  _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   1,  -3,  3,
  *   3, - 5,  3,
  *   6, - 6,  4
  * ]);
  * matrix._qrIteration( q, r );
  *
  * @param { this } - The source matrix.
  * @param { q } - The destination Q matrix.
  * @param { r } - The destination R matrix.
  * @returns { Array } Returns a vector with the values of the diagonal of R.
  * @function _qrIteration
  * @throws { Error } An Error if ( this ) is not a matrix.
  * @class Matrix
  * @namespace wTools
  * @module Tools/math/Matrix
  */

function _qrIteration( q, r )
{
  let self = this;
  _.assert( _.Matrix.Is( self ) );
  //_.assert( !isNaN( self.clone().invert().scalarGet([ 0, 0 ]) ), 'Matrix must be invertible' )

  let cols = self.length;
  let rows = self.scalarsPerElement;

  if( arguments.length === 0 )
  {
    var q = _.Matrix.MakeIdentity( [ rows, cols ] );
    var r = _.Matrix.Make([ rows, cols ]);
  }

  let a = self.clone();
  let loop = 0;
  q.copy( _.Matrix.MakeIdentity( rows ) );


  while( a.isUpperTriangle() === false && loop < 1000 )
  {
    var qInt = _.Matrix.MakeIdentity([ rows, cols ]);
    var rInt = _.Matrix.MakeIdentity([ rows, cols ]);
    a._qrDecompositionHh( qInt, rInt );
    // Calculate transformation matrix
    q.mulLeft( qInt );

    a._mul2Matrices( rInt, qInt );

    loop = loop + 1;
  }

  q.copy( q );
  r.copy( a );

  if( loop === 1000 )
  {
    r.copy( rInt );
  }

  let eigenValues = self.vectorAdapter.toLong( a.diagonalVectorGet() );
  eigenValues.sort( ( a, b ) => b - a );

  logger.log( 'EI', eigenValues)
  for( let i = 0; i < eigenValues.length; i++ )
  {
    let newValue = eigenValues[ i ];
    for( let j = 0; j < eigenValues.length; j++ )
    {
      let value = r.scalarGet( [ j, j ] );

      if( newValue === value )
      {
        let oldColQ = q.colGet( i ).clone();
        let oldValue = r.scalarGet( [ i, i ] );

        q.colSet( i, q.colGet( j ) );
        q.colSet( j, oldColQ );

        r.scalarSet( [ i, i ], r.scalarGet( [ j, j ] ) );
        r.scalarSet( [ j, j ], oldValue );
      }
    }
  }

  return r.diagonalVectorGet();
}

//

/**
  * Perform the QR Gram-Schmidt decomposition of a M matrix into a Q and a R matrices, where M = Q*R, R is
  * upper triangular, and Q is orthogonal. Matrix stays unchanged.
  *
  * @example
  * // returns Q = _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   0.857143, -0.467324, -0.216597,
  *   0.428571, 0.880322, -0.203369,
  *   -0.285714, -0.081489, -0.954844
  * ]);
  * returns R = _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   14, 34.714287, -14,
  *   0, 172.803116, -58.390148,
  *   0, 0, 52.111328
  * ]);
  *
  * var matrix =  _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   12, -51, 4,
  *   6, 167, -68,
  *   -4, -24, -41,
  * ]);
  * matrix._qrDecompositionGS( q, r );
  *
  * @param { this } - The source matrix.
  * @param { q } - The destination Q matrix.
  * @param { r } - The destination R matrix.
  * @function _qrDecompositionGS
  * @throws { Error } An Error if ( this ) is not a matrix.
  * @throws { Error } An Error if ( q ) is not a matrix.
  * @throws { Error } An Error if ( r ) is not a matrix.
  * @class Matrix
  * @namespace wTools
  * @module Tools/math/Matrix
  */

function _qrDecompositionGS( q, r )
{
  let self = this;

  _.assert( _.Matrix.Is( self ) );
  _.assert( _.Matrix.Is( q ) );
  _.assert( _.Matrix.Is( r ) );

  let cols = self.length;
  let rows = self.scalarsPerElement;

  _.assert( !isNaN( self.clone().invert().scalarGet([ 0, 0 ]) ), 'Matrix must be invertible' )

  let matrix = self.clone();
  q.copy( _.Matrix.MakeIdentity( [ rows, cols ] ) );

  let qInt = _.Matrix.MakeIdentity([ rows, cols ]);

  for( let i = 0; i < cols; i++ )
  {
    let col = matrix.colGet( i );
    let sum = self.vectorAdapter.from( self.long.longMakeZeroed( rows ) );
    for( let j = 0; j < i ; j ++ )
    {
      let dot = self.vectorAdapter.dot( col, self.vectorAdapter.from( qInt.colGet( j ) ) );
      debugger;

      self.vectorAdapter.add( sum, self.vectorAdapter.mul( self.vectorAdapter.from( qInt.colGet( j ) ).clone(), - dot ) );
    }
    let e = self.vectorAdapter.normalize( self.vectorAdapter.add( col.clone(), sum ) );
    qInt.colSet( i, e );
  }

  // Calculate R
  r._mul2Matrices( qInt.clone().transpose(), matrix );

  // Calculate transformation matrix
  q.mulLeft( qInt );
  let a = _.Matrix.Make([ cols, rows ]);
}

//

/**
  * Perform the QR Householder decomposition of a M matrix into a Q and a R matrices, where M = Q*R, R is
  * upper triangular, and Q is orthogonal. Matrix stays unchanged.
  *
  * @example
  * // returns Q = _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   -0.857143, 0.467324, -0.216597,
  *   -0.428571, -0.880322, -0.203369,
  *   0.285714, 0.081489, -0.954844
  * ]);
  * returns R = _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   -14, -34.714287, 14,
  *   0, -172.803116, 58.390148,
  *   0, 0, 52.111328
  * ]);
  *
  * var matrix =  _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   12, -51, 4,
  *   6, 167, -68,
  *   -4, -24, -41,
  * ]);
  * matrix._qrDecompositionHh( q, r );
  *
  * @param { this } - The source matrix.
  * @param { q } - The destination Q matrix.
  * @param { r } - The destination R matrix.
  * @function _qrDecompositionHh
  * @throws { Error } An Error if ( this ) is not a matrix.
  * @throws { Error } An Error if ( q ) is not a matrix.
  * @throws { Error } An Error if ( r ) is not a matrix.
  * @class Matrix
  * @namespace wTools
  * @module Tools/math/Matrix
  */

function _qrDecompositionHh( q, r )
{
  let self = this;
  let cols = self.length;
  let rows = self.scalarsPerElement;

  _.assert( _.Matrix.Is( self ) );
  _.assert( _.Matrix.Is( q ) );
  _.assert( _.Matrix.Is( r ) );

  let matrix = self.clone();

  q.copy( _.Matrix.MakeIdentity( rows ) );
  let identity = _.Matrix.MakeIdentity( rows );

  /* Calculate Q */

  for( let j = 0; j < cols; j++ )
  {
    let u = self.vectorAdapter.from( self.long.longMakeZeroed( rows ) );
    let e = identity.clone().colGet( j );
    let col = matrix.clone().colGet( j );

    for( let i = 0; i < j; i ++ )
    {
      col.eSet( i, 0 );
    }
    let c = 0;

    if( matrix.scalarGet( [ j, j ] ) > 0 )
    {
      c = 1;
    }
    else
    {
      c = -1;
    }

    u = self.vectorAdapter.add( col, e.mul( c*col.mag() ) ).normalize();

    debugger;
    let m = _.Matrix.Make( [ rows, cols ] ).fromVectors_( u, u );
    let mi = identity.clone();
    debugger;
    let h = mi.addAtomWise( m.mul( - 2 ) );
    debugger;
    q.mulLeft( h );

    matrix = _.Matrix.Mul( null, [ h, matrix ] );
  }

  r.copy( matrix );

  // Calculate R
  // r._mul2Matrices( h.clone().transpose(), matrix );
  let m = _.Matrix.Mul( null, [ q, r ] );
  let rb = _.Matrix.Mul( null, [ q.clone().transpose(), self ] )

  for( let i = 0; i < rows; i++ )
  {
    for( let j = 0; j < cols; j++ )
    {
      if( m.scalarGet( [ i, j ] ) < self.scalarGet( [ i, j ] ) - 1E-4 ) /* xxx */
      {
        throw _.err( 'QR decomposition failed' );
      }
      if( m.scalarGet( [ i, j ] ) > self.scalarGet( [ i, j ] ) + 1E-4 )
      {
        throw _.err( 'QR decomposition failed' );
      }
    }
  }

}

//


/**
  * Create a matrix out of a two vectors multiplication. Vectors stay unchanged.
  *
  * @example
  * // returns M = _.Matrix.Make( [ 3, 3 ] ).copy
  * ([
  *   0, 0, 0,
  *   3, 3, 3,
  *   6, 6, 6
  * ]);
  *
  * var v1 =  self.vectorAdapter.from( [ 0, 1, 2 ] );
  * var v2 =  self.vectorAdapter.from( [ 3, 3, 3 ] );
  * matrix.fromVectors_( v1, v2 );
  *
  * @param { v1 } - The first source vector.
  * @param { v2 } - The second source vector.
  * @function fromVectors_
  * @throws { Error } An Error if ( this ) is not a matrix.
  * @throws { Error } An Error if ( q ) is not a matrix.
  * @throws { Error } An Error if ( r ) is not a matrix.
  * @class Matrix
  * @namespace wTools
  * @module Tools/math/Matrix
  */

function fromVectors_( v1, v2 ) /* xxx : remove? */
{

  _.assert( _.vectorAdapterIs( v1 ) );
  _.assert( _.vectorAdapterIs( v2 ) );

  let matrix = _.Matrix.Make( [ v1.length, v2.length ] );

  for( let i = 0; i < v1.length; i ++ )
  {
    for( let j = 0; j < v2.length; j ++ )
    {
      matrix.scalarSet( [ i, j ], v1.eGet( i )*v2.eGet( j ) );
    }
  }

  return matrix;
}

//

/**
  * Split a M matrix into a U, a S and a V matrices, where M = U*S*Vt, S is diagonal
  * and the values of its diagonal are the eigenvalues of M, and U and V is orthogonal.
  * Matrix stays unchanged.
  *
  * @example
  * // returns:
  * var u =  _.Matrix.Make( [ 2, 2 ] ).copy
  * ([
  *   -Math.sqrt( 2 ) / 2, -Math.sqrt( 2 ) / 2,
  *   -Math.sqrt( 2 ) / 2, Math.sqrt( 2 ) / 2
  * ]);
  * var s =  _.Matrix.Make( [ 2, 2 ] ).copy
  * ([
  *   6.000, 0.000,
  *   0.000, 2.000,
  * ]);
  * var v =  _.Matrix.Make( [ 2, 2 ] ).copy
  * ([
  *   -Math.sqrt( 2 ) / 2, Math.sqrt( 2 ) / 2,
  *   -Math.sqrt( 2 ) / 2, -Math.sqrt( 2 ) / 2
  * ]);
  *
  * var matrix =  _.Matrix.Make( [ 2, 2 ] ).copy
  * ([
  *   2, 4,
  *   4, 2
  * ]);
  * matrix.svd( u, s, v );
  *
  * @param { this } - The source matrix.
  * @param { u } - The destination U matrix.
  * @param { s } - The destination S matrix.
  * @param { v } - The destination V matrix.
  * @function svd
  * @throws { Error } An Error if ( this ) is not a matrix.
  * @throws { Error } An Error if ( arguments.length ) is not three.
  * @class Matrix
  * @namespace wTools
  * @module Tools/math/Matrix
  */

function svd( u, s, v )
{
  let self = this;
  _.assert( _.Matrix.Is( self ) );
  _.assert( arguments.length === 3 );

  let dims = _.Matrix.DimsOf( self );
  let cols = dims[ 1 ];
  let rows = dims[ 0 ];
  let min = rows;
  if( cols < rows )
  min = cols;

  if( arguments[ 0 ] == null )
  var u = _.Matrix.Make([ rows, rows ]);

  if( arguments[ 1 ] == null )
  var s = _.Matrix.Make([ rows, cols ]);

  if( arguments[ 2 ] == null )
  var v = _.Matrix.Make([ cols, cols ]);

  if( self.isSymmetric() === true )
  {
    let q =  _.Matrix.Make( [ cols, rows ] );
    let r =  _.Matrix.Make( [ cols, rows ] );
    let identity = _.Matrix.MakeIdentity( [ cols, rows ] );
    self._qrIteration( q, r );

    let eigenValues = r.diagonalVectorGet();
    for( let i = 0; i < cols; i++ )
    {
      if( eigenValues.eGet( i ) >= 0 )
      {
        u.colSet( i, q.colGet( i ) );
        s.colSet( i, identity.colGet( i ).mul( eigenValues.eGet( i ) ) );
        v.colSet( i, q.colGet( i ) );
      }
      else if( eigenValues.eGet( i ) < 0 )
      {
        u.colSet( i, q.colGet( i ).mul( - 1 ) );
        s.colSet( i, identity.colGet( i ).mul( - eigenValues.eGet( i ) ) );
        v.colSet( i, q.colGet( i ).mul( - 1 ) );
      }
    }
  }
  else
  {
    let aaT = _.Matrix.Mul( null, [ self, self.clone().transpose() ] );
    let qAAT = _.Matrix.Make( [ rows, rows ] );
    let rAAT = _.Matrix.Make( [ rows, rows ] );

    aaT._qrIteration( qAAT, rAAT );
    let sd = _.Matrix.Mul( null, [ rAAT, qAAT.clone().transpose() ] )

    u.copy( qAAT );

    let aTa = _.Matrix.Mul( null, [ self.clone().transpose(), self ] );
    let qATA = _.Matrix.Make( [ cols, cols ] );
    let rATA = _.Matrix.Make( [ cols, cols ] );

    aTa._qrIteration( qATA, rATA );

    let sd1 = _.Matrix.Mul( null, [ rATA, qATA.clone().transpose() ] )

    v.copy( qATA );

    let eigenV = rATA.diagonalVectorGet();

    for( let i = 0; i < min; i++ )
    {
      if( eigenV.eGet( i ) !== 0 )
      {
        let col = u.colGet( i ).slice();
        let m1 = _.Matrix.Make( [ col.length, 1 ] ).copy( col );
        let m2 = _.Matrix.Mul( null, [ self.clone().transpose(), m1 ] );

        v.colSet( i, m2.colGet( 0 ).mul( 1 / eigenV.eGet( i ) ).normalize() );
      }
    }

    for( let i = 0; i < min; i++ )
    {
      s.scalarSet( [ i, i ], Math.sqrt( Math.abs( rATA.scalarGet( [ i, i ] ) ) ) );
    }

  }

}

// --
// relations
// --

let Extension =
{

  _qrIteration,
  _qrDecompositionGS,
  _qrDecompositionHh,

  fromVectors_,

  svd,

}

_.classExtend( Self, Extension );

})();
