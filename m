From: Harald Welte <laforge@gnumonks.org>
Subject: Re: primary and secondary ip addresses
Date: Sun, 19 Dec 2004 22:41:20 +0100
Message-ID: <20041219214120.GX17302@sunbeam.de.gnumonks.org>
References: <41912F7A.6000408@redhat.com> <200412161153.51251.hasso@estpak.ee> <Pine.LNX.4.61.0412161103320.30452@filer.marasystems.com> <200412161302.42357.hasso@estpak.ee> <41C2F6E5.5010607@cs.columbia.edu> <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com> <41C30212.6000906@cs.columbia.edu> <20041217112025.27688eb6.davem@davemloft.net> <Pine.LNX.4.61.0412172046320.18698@filer.marasystems.com> <1103487517.1047.181.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xi8lRpXYeGgNnUjs"
Cc: Henrik Nordstrom <hno@marasystems.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrea G Forte <andreaf@cs.columbia.edu>, hasso@estpak.ee,
	nhorman@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103487517.1047.181.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xi8lRpXYeGgNnUjs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Dec 19, 2004 at 03:18:37PM -0500, jamal wrote:

> Having said the above, I think it would make sense to have a "promotion"
> scheme so that in the case a primary address is deleted, one could
> promote the next secondary address in line. But that should be optional.

Oh yes, please.  This would save a lot of headache.  I'm much in favour
of such a proposal.

> Now where is the fireman who wants to do this? I could help cheering
> since i know the code.

how would you think it fits best into the current netlink messages?

> cheers,
> jamal

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--xi8lRpXYeGgNnUjs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBxfWAXaXGVTD0i/8RAhzGAJ42/15fWwkV1AeR+SECS1JNOp5AUACgswb1
C+lV9lUxoaVp7VW08PfAqXQ=
=eAwb
-----END PGP SIGNATURE-----

--xi8lRpXYeGgNnUjs--
