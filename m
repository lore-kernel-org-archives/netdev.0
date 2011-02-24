From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: warn if max_vfs limit is exceeded
Date: Thu, 24 Feb 2011 03:23:16 -0800
Message-ID: <1298546596.2643.27.camel@jtkirshe-MOBL1>
References: <4D663ADD.4040708@redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-d8xEfv4tzVOMh6fL8L8d"
Cc: netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10131 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756044Ab1BXLXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 06:23:16 -0500
In-Reply-To: <4D663ADD.4040708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-d8xEfv4tzVOMh6fL8L8d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-02-24 at 03:02 -0800, Stefan Assmann wrote:
> From: Stefan Assmann <sassmann@redhat.com>
>=20
> Currently there's no warning printed when max_vfs > 7 is specified
> with
> igb and the maximum of 7 is silently enforced. This patch prints a
> warning and informs the user of the actions taken.
>=20
> Signed-off-by: Stefan Assmann <sassmann@redhat.com>
> ---
>  drivers/net/igb/igb_main.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)=20

Thanks for the patch Stefan.  I have added the patch to my igb queue of
patches.

--=-d8xEfv4tzVOMh6fL8L8d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNZj+jAAoJECTsCADr/EWUkwwH/iQm6Uqh+DuyRKUZkg1XbLe9
6F8P/UZSWdw052npiuUVydvKKgea9a8SWrc+mxhYVX+h+Y5qBQhc9OJjZy3xvIYt
12Mt09ltpH81EsNXdAzyjQQRtKxgP/+OWyFwCPW8DspVUi3MSDpKWsG+CHIjU0XM
8DVwdCPijki9GEOVJxO+KlT5CRE3u31mHBRlU0LWLimLPIHP3ilf2GxlhO+x4eP4
DzOKRaWlB1ABFO4SqcdQgsUih4dYzaOJTXcJfQgVriY0Srh6ywvt3HN1Gfe1qBLB
rh7irZjAu+JZIsO4BatSsLNuQQBZJ2K40KiUAKxg0gvjnM1H4JzYHDC63ZSpy+w=
=OMSA
-----END PGP SIGNATURE-----

--=-d8xEfv4tzVOMh6fL8L8d--

