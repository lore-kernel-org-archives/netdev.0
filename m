From: Phil Dibowitz <phil@ipom.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 14:04:12 -0700
Message-ID: <20060525210412.GC29024@ipom.com>
References: <20060525175947.GA29024@ipom.com> <200605251341.42204.bcook@bpointsys.com> <20060525192239.GB29024@ipom.com> <20060525.132928.115910730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qjNfmADvan18RZcF"
Cc: bcook@bpointsys.com, billfink@mindspring.com, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-24-24-245-191.socal.res.rr.com ([24.24.245.191]:54847 "EHLO
	alt") by vger.kernel.org with ESMTP id S1751258AbWEYVEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 17:04:13 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060525.132928.115910730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qjNfmADvan18RZcF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 25, 2006 at 01:29:28PM -0700, David Miller wrote:
> From: Phil Dibowitz <phil@ipom.com>
> Date: Thu, 25 May 2006 12:22:39 -0700
>=20
> > So at least, for the _current_ implimentations, this should have no
> > performance impacts.
>=20
> Regardless, I think this is something that userspace _can_
> take care of reasonably and therefore has no buisness in the
> kernel.
>=20
> We do not duplicate functionality that is already possible
> _unless_ it is incredibly difficult for userland to do so.
> And in this case I do not think it is difficult for userland
> to interpret the counters in the way you want it to.
>=20
> So, major NACK on this stuff.

Well, if that's how you feel, I'm probably not going to change your mind,
though I'll emphasize I think any solution in userspace is a work around -
*particularly* since most cards have a command specifically for "clear
stats"... why would specifically not support a _feature_ of the hardware.

--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety."
 - Benjamin Franklin, 1759


--qjNfmADvan18RZcF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEdhvMN5XoxaHnMrsRAnJIAJ9qO/AvqmG5li3Hw+L2TYv9no6sRwCfc+Md
MwjpxiiaL3BxZaoWAa6Dgf4=
=ZWt1
-----END PGP SIGNATURE-----

--qjNfmADvan18RZcF--
