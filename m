From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2] wlcore: remove newly introduced alloc/OOM messages
Date: Mon, 11 Feb 2013 10:24:55 +0200
Message-ID: <20130211082455.GC25438@arwen.pp.htv.fi>
References: <1360569218.12803.50.camel@cumari.coelho.fi>
 <1360570878-23107-1-git-send-email-coelho@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zCKi3GIZzVBPywwA"
Cc: <linville@tuxdriver.com>, <sfr@canb.auug.org.au>,
	<joe@perches.com>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1360570878-23107-1-git-send-email-coelho@ti.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--zCKi3GIZzVBPywwA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 11, 2013 at 10:21:18AM +0200, Luciano Coelho wrote:
> In commit 0d2e7a5c (wireless: Remove unnecessary alloc/OOM messages,
> alloc cleanups) OOM messages after alloc were removed from the wlcore
> modules.
>=20
> Commit afb43e6d (wlcore: remove if_ops from platform_data)
> reintroduced a couple of those.  This patch removes them.
>=20
> Signed-off-by: Luciano Coelho <coelho@ti.com>

looks good now :-)

Reviewed-by: Felipe Balbi <balbi@ti.com>

--=20
balbi

--zCKi3GIZzVBPywwA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRGKrWAAoJEIaOsuA1yqREOP0P/2II+Klb2tHEiufMZ2/eHrp2
v7czWMgtZV0+B9fxOw1CVWT3+5Y6mngVgk12E5in79qIGUzHpjsYbfRo2vAy1HoM
n9hzCTo1mofLFFj5GQdr7BoHCvuAAfno7y/wZW6aVNDq8jguBJc3KqE3BctiT9UC
rhAWoXTVreEwPjQuTGG8kvEK15GtcMZ6mZ14MtH7NvB4sK1lQXAyOKQyIJVbu1uc
Yrvkn1Mxy6cWape50U2carFHNvisCJ0Xmh47kKtIcTzRmtCbBrIMF7Mh4O6zUD+7
7fbum+AFkM+52e7VztFeDmBhg0pVKtUXR7vLHRJ5TswJgUbUTuMMmyWiuJ7dYRBN
vqni7U271FNzdlnpVPJ/dscaOjCTrjucw1wRyermeVVz7YS40ZNfRrYO8vgiI5m9
1CXrO4GTn+11RqjKfig0BSP6ct9W01HZixHWUDSm06WFGPTNi8JQFuKVZPmOjI4e
xkFqc+dUKqCGgmnb4QDb+ahioPObomWSu3KutyZRcMFNEG4yCPD2kHbpn4nv3sl1
ZbZdjmbAA2FiNLC6+Q5tH6w06TxlSplkeuwdspiDg1bXYJ5TAFNYUO3lphSBdbZ2
xAhz7sMdjBcrcyhtYJjCyfADauGKdBn+t3TOBM20efBo74GkaJQop2jkAReA3ShR
c+m+tnX7hjqPlis8H9bV
=yYrk
-----END PGP SIGNATURE-----

--zCKi3GIZzVBPywwA--
