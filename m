From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Thu, 15 Nov 2012 22:25:58 -0800
Message-ID: <1353047158.2337.92.camel@jtkirshe-mobl>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
	 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
	 <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com>
	 <CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
	 <50A570D7.3080409@gmail.com>
	 <1353022205.4867.76.camel@deadeye.wl.decadent.org.uk>
	 <CAPN4dA_ymo-Bx+GM+JLLKGHghq+qBYxR0zO7K6H6Nn0pqZsJRg@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6uy6zYZA3puu4mpw/RPJ"
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: footplus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4519 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab2KPG0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 01:26:00 -0500
In-Reply-To: <CAPN4dA_ymo-Bx+GM+JLLKGHghq+qBYxR0zO7K6H6Nn0pqZsJRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6uy6zYZA3puu4mpw/RPJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-11-16 at 03:23 +0100, Aur=C3=A9lien wrote:
> On Fri, Nov 16, 2012 at 12:30 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> >
> > Yes, Jeff's the one you should be talking to about these drivers.  I
> > just look after the ethtool utility and API.
> >
>=20
> Ok, so I will discuss the ixgbe patch with Jeff :)

Aur=C3=A9lien-

As far as your driver changes go and the questions you have, Don
Skidmore (ixgbe maintainer) and I have been discussing your patch and
may have some implementation changes possibly to suggest.  I will talk
with Don more tomorrow about it before I suggest any changes.

As far as your questions regarding ixgbe PHY's, I will have Don respond
your questions.  I have CC'd Don <donald.c.skidmore@intel.com> as well
on this email thread.

Cheers,
Jeff

--=-6uy6zYZA3puu4mpw/RPJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQpdx2AAoJEOVv75VaS+3OTNwP/0B3qHfWOJ6BJ9UHEStIZTSC
8kQOspXW9a+S/upsDQqOSWM93lneChMnAQXEd2Wex2o04HY2x3iH3KgFBDZo+vwO
E07q+n9cNYiS9JFzS+ed1RZDnVKpuFJYqKmH3IipbVW6gVfGGvyxRb9dyO+gWsWZ
5MxulTPqYxbtXcgBsTO88fVee99/JrZwlZviLoIzNQIfUh60FH3hWMkchImlthWu
KPMAnGXnL3EavnsfOGPBOXZkFXG0PHvF2Nj67sxs7FWI6r+XiStvZdHIv7y/66BD
7x7pbVDkPNO8Gb2852lBMGflXo3T2E/N0HIt9f0diNKsgO6MGlLq60bJ8CBiU5zS
61fcrqJeFCjouo4rjB0giN1cLq09VaXAqPcn5rrc2McGaI8WDpqMjxU9UdJ82zLw
KM8LWEseJ9nK8cj5aKlYnp+ezuv62bZlXpbAf/+5/M6dEOJACwYqpEShJtFsuu5D
TyvEQcaK9Q8P0UdLpJ8l2+g4/OYclsuryv2N8ExWXBA+qmWNXPzq/QzhTV5QEDyx
aRiIv9pNGuDKWd//C2BqC9PCzpcSj2EeMyUnBwMUr0pWg3UNdizgJmUKRtomyse4
s6NUEPoxamDXoXeWzKriJBJmoDNSUrHG/TzrxxpLmZh2Xr6pcDuNP0nK0KiDowlo
Fy/732VvMcua8QOIMoRT
=hyAz
-----END PGP SIGNATURE-----

--=-6uy6zYZA3puu4mpw/RPJ--
