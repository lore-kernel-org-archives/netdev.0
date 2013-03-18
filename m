From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH][v3.2.y] xen-netfront: delay gARP until backend switches
	to Connected
Date: Mon, 18 Mar 2013 02:19:40 +0000
Message-ID: <1363573180.3937.302.camel@deadeye.wl.decadent.org.uk>
References: <514360DD.8050406@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2514430793949366686=="
Cc: jeremy@goop.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <514360DD.8050406@canonical.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============2514430793949366686==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aOtK/I3oqy0L3172kZ2X"


--=-aOtK/I3oqy0L3172kZ2X
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-03-15 at 13:56 -0400, Joseph Salisbury wrote:
> Hello,
>=20
> Please consider including upstream commit=20
> 08e34eb14fe4cfd934b5c169a7682a969457c4ea in the next v3.2.y release.
> It was included upstream as of v3.3-rc1.  It has been tested and=20
> confirmed to resolve http://bugs.launchpad.net/bugs/1154608 .
>=20
> commit 08e34eb14fe4cfd934b5c169a7682a969457c4ea
> Author: Laszlo Ersek <lersek@redhat.com>
> Date:   Sun Dec 11 01:48:59 2011 +0000
>=20
>      xen-netfront: delay gARP until backend switches to Connected

Added to the queue, thanks.

Ben.

--=20
Ben Hutchings
Never attribute to conspiracy what can adequately be explained by stupidity=
.

--=-aOtK/I3oqy0L3172kZ2X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUUZ5vOe/yOyVhhEJAQrw5Q//WtD/ICjdtXSZyb6+adAXGf20091dXQYO
yWvuLEouKVwgyPtsmvKpBjzkTD8NyD+oZkULIpgbd7bSmoywJzNBpDBfTudLEQyw
4FSeYvvOe03cLOu1f1YAOiFh3LGmCUeitjxmE9/CNpUS7rItSxz+8XsXswHtg0t0
LyC+1rDLX6rGJ5zw6eZXz4wQ0E+wX6cD/D/8g08yoA/uDGnqxiJX2x3LSpuKI+tE
PKUJA67XhaA6hThipJwHESjejQ6v8gJBs5QAC2Smc0/nK1LpYoF1zfDRjo/4aK6W
u1ByISdbk7GejhnM1Gp3nSbxvfnxOnGaIUz4DgQ/mVBr9HE2CmF/2zYIM4LLW0u3
gVs+c+NsE2MtC1u2rQYQtsBmUGld7pkxoohCbof9t81TqfiiMLaqHEtB2xmG819P
OlexWtUgI0xQ9UmFClH1wWbRRYfe3QL1ogwBfIhREjYIyn6oViQ7+PakhEAKwz7u
qgpyL5nzBt02Jq0SwrXpClnJdw5CxYWwPZr1m+3FCpzY/GqsHS7YmSAZbRHKNSxN
Ugq5ActHsGM8ppG06Y5VPR2Z734p5kI4Ipc9K7wNq/7saaneiTHyqnURHk9biJcr
unI3CPZS8HxU6XMvNocD5NJVMSuZzFs1s+P2H+WmFXZrlU16zS+f+2M4CetWm2/Q
7vGOa+yp+AU=
=0cSp
-----END PGP SIGNATURE-----

--=-aOtK/I3oqy0L3172kZ2X--

--===============2514430793949366686==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============2514430793949366686==--
