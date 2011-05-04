From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 0/9][pull request] Intel Wired LAN Driver Update
Date: Wed, 04 May 2011 14:14:44 -0700
Message-ID: <1304543684.2998.6.camel@jtkirshe-MOBL1>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110504.135621.232749554.davem@davemloft.net>
	 <20110504.135904.229767743.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Dc53M5L/CqIMwFTmpF0a"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47094 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753596Ab1EDVOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 17:14:44 -0400
In-Reply-To: <20110504.135904.229767743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Dc53M5L/CqIMwFTmpF0a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-05-04 at 13:59 -0700, David Miller wrote:
> BTW, Jeff, can I get some kind of time frame on when the ethtool_ops->phy=
s_id
> conversions/removals for e100, e1000, and igb will be coming my way?
>=20
> It's starting to be on the order of weeks that I've been waiting for
> this so that I can apply Stephen Hemminger's patch which gets rid of
> the old ->phys_id interfaces entirely.
>=20
> Thanks.

I have the remaining patches in testing currently.  Should have the
remaining three patches to you by this weekend (if not sooner).

--=-Dc53M5L/CqIMwFTmpF0a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNwcHEAAoJECTsCADr/EWUUwsH/jp2OR0lY14KttytAgJjMD+X
KvOQ8ns0R1Lz33w2QOS0p/iD2W9ljmNgxYHmMwe1UHJpmPJrXB+dBpG5BeeQLuWm
FNxWT7yf4qlbO9S4PfCHLFDDCNdAeoL1Bb2nQFw1lfxCk6YJMJwk3dlRAf7ds+TT
623Km8/7d7DrDC/FRc1PxVWvH93FkBW/kvyHS/lrOBRehUxwyyesfigelU6cFD6a
i0/Hzc25yQXfJtVi2JwCwwQthLbrPcmSsa5Ld/ibj5x5aq51Ia3Q+TXMqdAkRfYb
fKqcegUhXQjx1/Vx27CXTGeJw+fPHOpF+8t5mzyInASAQtGf/9z38C2/RZM21Aw=
=UBQB
-----END PGP SIGNATURE-----

--=-Dc53M5L/CqIMwFTmpF0a--

