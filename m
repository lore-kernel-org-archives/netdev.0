From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net  8/8] i40e: include i40e in kernel proper
Date: Wed, 11 Sep 2013 08:25:48 -0700
Message-ID: <1378913148.2026.17.camel@jtkirshe-mobl>
References: <1378893056-4821-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378893056-4821-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378902002.606.42.camel@joe-AO722> <1378909937.2026.8.camel@jtkirshe-mobl>
	 <1378910832.4714.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Th1DPQC9UbMENxfnM0Ea"
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14126 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451Ab3IKPZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 11:25:51 -0400
In-Reply-To: <1378910832.4714.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Th1DPQC9UbMENxfnM0Ea
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-09-11 at 07:47 -0700, Joe Perches wrote:
> On Wed, 2013-09-11 at 07:32 -0700, Jeff Kirsher wrote:
> > On Wed, 2013-09-11 at 05:20 -0700, Joe Perches wrote:
> > > On Wed, 2013-09-11 at 02:50 -0700, Jeff Kirsher wrote:
> > > > New driver build option is CONFIG_I40E
> > >=20
> > > > diff --git a/Documentation/networking/00-INDEX b/Documentation/netw=
orking/00-INDEX
> > > []
> > > > +i40e.txt
> > > > +	- README for the Intel Ethernet Controller XL710 Driver (i40e).
> > >=20
> > > Just curious but why the XL710 / i40e name mismatch?
> >=20
> > i40e stands for Intel 40 GbE Ethernet which is more generic than naming
> > the driver the same as the first part (XL710).
>=20
> Too bad if also means that when 100 comes out
> this driver won't be expected to work.

It will work for our 40GbE parts definitely, as far as future technology
and silicon, I cannot say.

--=-Th1DPQC9UbMENxfnM0Ea
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSMIt8AAoJEOVv75VaS+3OaJQQAIXyCgDBdHOYEf7jEkNJfDeY
oe2Jkkdy7PIlh3UNRhiRePNxB+3T6QN4c0apan0/rJOK/fhUPIShvWc7HwFoAlLr
eyJuofz+udltL3tOSOyH4x/tJeo/ChGYaij3fg78UgqXrNSsft39BWqMCqOXl1be
AwrshaRJ6/+XHBJsmAuTD6+tbnUOGz6nMeDENRQn/Vi1ydE5tvxCzKvWhjMAPgoO
O7aZ2n1OfKKKjnsQH0WuzkA6JJiICvc62FRqF5exK/oUx0Q99+Sw0ZGbLrldeafk
3ndbF0zNubfH9KCpn1QhREEH26wLGcVFhG5z119XWMi4VjpuOlGN9NqLvl864Nvg
6U8Xv722dHMRfQ0hgCIrCizTncqb94Y85DB4Z/q8mZ4zueARFEB/ihoyiNFu/G2B
0gzbuIpkscVqmA435nETDSoJ2oCR+a6tFtnQh0c2npgzBH4ka4HcyRgn3EVTV2JI
xGECp8RCGGvTT7IHG+hQcflH0HNCwpvnoRIkfJQVB9VgZboh7RYfmR/+AVvbryGl
K6TrPI3czEPEBdmoOZ52J7gHo2gNqirR2eFJrFwDbBu1aVkvDxa0UT3QlQewqJM3
kXLbYT2Tef+C0v3wZjEWSIaa0ej4P5u6kkQHwCaMOQrfE13btR9rll9rtXJPekWQ
8NDAM/H0XWMc1uXJtyZF
=VD8i
-----END PGP SIGNATURE-----

--=-Th1DPQC9UbMENxfnM0Ea--
