From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 48/71] octeon: Move the Cavium driver
Date: Tue, 02 Aug 2011 21:59:45 -0700
Message-ID: <1312347586.2294.56.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-49-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4E387EB4.3080000@cavium.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-RQF7ziBbz2B6dW45OuTj"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	David Daney <ddaney@caviumnetworks.com>
To: David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30219 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315Ab1HCFAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 01:00:00 -0400
In-Reply-To: <4E387EB4.3080000@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RQF7ziBbz2B6dW45OuTj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-08-02 at 15:48 -0700, David Daney wrote:
> On 07/30/2011 08:27 PM, Jeff Kirsher wrote:
> > Move the Cavium driver to drivers/net/ethernet/octeon/ and
> > make the necessary Kconfig and Makefile changes.
> >
> > CC: David Daney<ddaney@caviumnetworks.com>
> > Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>=20
> Acked-by: <david.daney@cavium.com>
>=20
> I haven't tested the patch, but it looks good to me.  I will fix any=20
> breakage that may occur after the patch is merged.
>=20
> Thanks.
> David Daney
>=20

Thank you, that is nice to hear!

--=-RQF7ziBbz2B6dW45OuTj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOONXBAAoJECTsCADr/EWUJTgH+gM7cJe7i2RSunXqg9faLLPy
b1GbS/C1pXYyLO1lo9hfFolNoMJX1VX+kxu3De7LxQRQ490RypqZpLr//EuIlAuu
ATW/JFF2CGhVmpKx1YCpN13gJ36QvRSoF4iEIS+TkFV2kelyAt+4mzKv9XQtQPFy
LV7bGSc7SLevlh7QDDfsRim9rBaOsufIyKzgxHtTlWKeLjmUFy7h1rJr+6oipTd7
01/fyMksnz8sVEm0sfmEHNhAAiWa37SEWUWw4IeUr/xQkUsZc8YMY8piemHaT1sU
va0SUIg0lB2eTrDyghhKvvO73C0vax0uuz6p6NLaXquLw/lCOx5A6V6KkMbTAKc=
=Snoc
-----END PGP SIGNATURE-----

--=-RQF7ziBbz2B6dW45OuTj--

