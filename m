From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Mon, 25 Jul 2016 08:06:49 +0300
Message-ID: <20160725050649.GX20674@leon.nu>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
 <20160715050005.GD30603@leon.nu>
 <578E0A65.1020105@annapurnalabs.com>
 <20160719172644.GK20674@leon.nu>
 <1468950597.1900.56.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ofQ+NWZjH2FySEVi"
Cc: Netanel Belgazal <netanel@annapurnalabs.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, benjamin.poirier@gmail.com,
	ben@decadent.org.uk, romieu@fr.zoreil.com, rami.rosen@intel.com,
	antoine.tenart@free-electrons.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468950597.1900.56.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ofQ+NWZjH2FySEVi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 19, 2016 at 10:49:57AM -0700, Joe Perches wrote:
> On Tue, 2016-07-19 at 20:26 +0300, Leon Romanovsky wrote:
> > On Tue, Jul 19, 2016 at 02:09:25PM +0300, Netanel Belgazal wrote:
> > > This is the debugging message interface.
> > > https://www.kernel.org/doc/Documentation/networking/netif-msg.txt
> > This document was updated last time in 2006 and I doubt that it is
> > relevant in 2016. You have dynamic debug prints infrastructure for it,
> > use it.
>=20
> I think this is uninformed.
>=20
> netif_<level> works well, is compatible with dynamic debug,
> and is commonly used with new networking drivers.
>=20

I have a very strong feeling that it is not "used in new drivers" by was
influenced (copied) from "old drivers". The same goes for real life usage of
module version which was introduced in this patch.

--ofQ+NWZjH2FySEVi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXlZ5oAAoJEORje4g2clinXx8QAIDbNLOUpdO3ph6Rt+lZkKln
kXWQp7AeFMZrUXKMhpYCj+rb/EJSIwlg+WD0vvRVzw9tGg1UGwUzhyyR6TO8anvr
+S4ttlB1dib1M6KPgi2kGttuKzT0DMotrnir6/gZpyO9RlPXc/ntv5DrMF+Lv7Uo
S2+m+oE7L4hkLsM2iP4f07vExUiuCXzCdav8lAKojmoML4l+Q1DYgYtfOXMDoNzX
CRmRc1oeArK2QHV9JYVxpz6fpwW9FQmMdXaXbe6gZeBWdMb1ga37u0V9EjqrGza0
aQ/YFXoYpa+OdxXJBBnCrTRed2r9EzJYh8XUJMIPm57iENOwwyqIPttR97t87CRM
kjxPmjSV7p0h6APF8mfqY7TIpcu+XKLNFJdOhhGYestJqqs1MIAaiIY47likO1lr
MScuMiRTizMa61TtK5SMxMvkjjRUTIPWVS0vEsk/4wynWcaYJ8BkA88O71vpGrRI
lnsx25nrWV0ZZEXSmE9d2Cz2vExOYpdvAAQxk6/gAl/KNklpXbbUFh+vUrRg8vnK
SR5nfzwrnIOCNc+ui9G4eWcloi079ZpiwVjk+Cz/eANEtnFIZy0w1s9tSQf7uE+o
fdsBgdmAmyMZBvLGn8y4rlpdMNJyrf/pGWMkvcdSQnklB+71Wn4ueOKQ1HpB/uQI
oc5CCy4qS9mFKmUdgXZc
=s+RE
-----END PGP SIGNATURE-----

--ofQ+NWZjH2FySEVi--
