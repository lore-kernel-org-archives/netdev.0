From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 05/15] igb: Support to read and export
 SFF-8472/8079 data
Date: Thu, 18 Apr 2013 16:41:55 -0700
Message-ID: <1366328515.2248.61.camel@jtkirshe-mobl>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1366327822-10741-6-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1366328268.2248.60.camel@jtkirshe-mobl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DiN9JaiHMXCHw7+wSikE"
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	=?ISO-8859-1?Q?Aur=E9lien?= Guillaume <footplus@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1263 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966999Ab3DRXmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:42:15 -0400
In-Reply-To: <1366328268.2248.60.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DiN9JaiHMXCHw7+wSikE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-04-18 at 16:37 -0700, Jeff Kirsher wrote:
> On Thu, 2013-04-18 at 16:30 -0700, Jeff Kirsher wrote:
> > From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
> >=20
> > This patch adds support to read and export SFF-8472/8079 (SFP data)
> > over i2c, through Ethtool.
> >=20
> > v2: Changed implementation to accommodate any offset within SFF
> module
> >     length boundary.
> >=20
> > Reported-by: Aur=C3=A9lien Guillaume <footplus@gmail.com>
> > CC: Aur=C3=A9lien Guillaume <footplus@gmail.com>
> > CC: Ben Hutchings <bhuntchings@solarflare.com>
>=20
> Looks like Akeem made a typo in your email Ben.

I have fixed up your email in the patch that resides in my net-next
tree.
>=20
> > Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>=20

--=-DiN9JaiHMXCHw7+wSikE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRcITDAAoJEOVv75VaS+3OF4MQAJrBi45EYCWGa9dyOTM3vJpO
3Etdgxj5rVuvrK8c+1APmIYC6lhegN+pijGF2AwpJAueMm5sIJHqwOJw041GrnGC
uzXSwqphXX7d3LZa4jQUCGufHvE45N2Kgex/4q1Ks1QdkpJuPJSy0JASdcRfdFU+
nE8jzAZ8484rq3aUTZ/ze8bntL6q1b1EAdMsQqy7R15vsYt0uVnUy8B/sPoutYZx
zXKBtOvSouDphmeKhlXR5o46+xAUyVjeExGRuRC25pAPlpuwWkJPoKPg7iJtxPdu
XS0py6yL0TsFOX5SS341IFw6vKiUn2rC16CPzyraO8nFkkWKeGDApOcRKIWzRygD
EY6gzrCIV8Hv+1WaOzQiwroeoIWTSq4Rx6rwJjHBIFJ0wzn6nwyGqf4HkKZZ7Iv0
XginkgUT8AHrqi45K23xqYy57nWrLhc42FjYwvxGmQGpsYR+H/KGWKqUtEJn8Q6+
569rKYeIevDHI5SzxDCYowTl/fDbouxI94xAVBAgt9Cn1BGfY6uKYZT4xRveSawW
2I2UkCYOSG9IeHzU8uD5IzmbHKre7pI7Fj4f5XJtFharQ5+m9S584XVsRZAz0C43
7z2v5vFA/4N3DYXN3u+oQ8+tMX3mmBwpn1vGH124A41TroPtXz/xWdiT/uubGecZ
iF8h6vLjawGP1dZQFub0
=EhB8
-----END PGP SIGNATURE-----

--=-DiN9JaiHMXCHw7+wSikE--
