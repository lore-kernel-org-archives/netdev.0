From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 02/10] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Thu, 11 Aug 2011 02:13:32 -0700
Message-ID: <1313054026.2339.3.camel@jtkirshe-mobl>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313033278-7337-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110811100255.421a5fbc@bob.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-QH6M/CQY3tYUNRaf1Bjy"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@tredhat.com" <gospo@tredhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	David Hinds <dahinds@users.sourceforge.net>
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13738 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753896Ab1HKJNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 05:13:46 -0400
In-Reply-To: <20110811100255.421a5fbc@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QH6M/CQY3tYUNRaf1Bjy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 02:02 -0700, Alan Cox wrote:
> On Wed, 10 Aug 2011 20:27:50 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>=20
> > Moves the 3Com drivers into drivers/net/ethernet/3com/ and the
> > necessary Kconfig and Makefile changes.
>=20
> This seems to be repeating one of the problems of the last one
>=20
> > drivers/net/{ =3D> ethernet/3com}/acenic.c         |    0
> > drivers/net/{ =3D> ethernet/3com}/acenic.h         |    0
>=20
> Acenic was not 3com. It was a wide variety of vendors including 3Com who
> rebadged it.
>=20
> Alan

Alan-

Where would you like to put it? drivers/net/ethernet/alteon/?  I am fine
with fixing this up by placing somewhere else.

--=-QH6M/CQY3tYUNRaf1Bjy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOQ508AAoJECTsCADr/EWUZY0IAK9WEJJ4vl82oW1ULxi83qsl
veHSXos4Ayv1y2Vo+jKaqn1dhbvfl5JmfDcrlU1cv9yJupzZNpZpJcVDtOsEcAfh
evJQlxbL43ymq19MmBjP6pi2uD2jDCXvHXCsnR1YSm/Z/LKrlwI7XSmZoxtwi9IH
kcAvS0/+tN4jSYcAXboNcuLU2kzD9F5ayBIqQTUJ5mNPsCSnk348GpVuVopQ0RHI
GnoUH4qgqpqFKWCcHtE7uZPfLk8Ni/QcjrBG4dV1KE7yPq9Jsosb/NuAVS/VV7Bo
fAYoiW7h/UGA+8FBQnQPohBAClElhzw1yrehlA7rTMxaG46JWSXypi1hMppfA84=
=1ITR
-----END PGP SIGNATURE-----

--=-QH6M/CQY3tYUNRaf1Bjy--

