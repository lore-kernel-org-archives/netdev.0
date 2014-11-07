From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] net/fm10k: Avoid double setting of NETIF_F_SG
 for the HW encapsulation feature mask
Date: Thu, 06 Nov 2014 22:44:15 -0800
Message-ID: <1415342655.2466.11.camel@jtkirshe-mobl>
References: <1415265664-10738-1-git-send-email-ogerlitz@mellanox.com>
	 <20141106.164423.844341922481879853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aZG12+MvOo4q1l6Meo+N"
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29917 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbaKGGoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 01:44:21 -0500
In-Reply-To: <20141106.164423.844341922481879853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aZG12+MvOo4q1l6Meo+N
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-06 at 16:44 -0500, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu,  6 Nov 2014 11:21:04 +0200
>=20
> > The networking core does it for the driver during registration time.
> >=20
> > Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>=20
> I assume Jeff will pick this up and send it to me via his tree.

Correct, I will add this to my queue of patches.

--=-aZG12+MvOo4q1l6Meo+N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUXGo/AAoJEOVv75VaS+3OKWoP/iYLodzn68xX6o8E6vgh3Jvh
jSTlMie5nJ/p+/9oWDs5/PEZk4qrfZFe5EQraEBZx8UbVFRhvpN83MxMkIVjy78u
JOiYkZokl0TY+ebNAXA0PjxXH2b16kWINPq5QdVYukMIUwQiXcKQTeC7lD6IqWfN
WOMFIZ6A0Yw4Ra2z5d3yqS+iYnVfowfGAUC5tj2IneUZI42W7AR/xXLUnD9YovY8
Udd4ITO70J+4k7IMnqgjMNZDVpyrkxMge4ttyeh4i0AU85IgC1yCB+ZzRyrNDCRE
XG9XIYekl3rlMOM2hK04ogiJDuGpv1FhFukI+SyNfte5CqBTr1mHKIV4UjhbK2Oq
J9fgeLeoD58W5IcnkhtbA0hFSHTb8NB4Y4D4ySBYf346PQHHNAFEYnYNY6bZuxkd
YWNkLUV1G5157J/v4kj/iqgrIH+1Upb4eMcaKcm+fyQsGxA8HHzxyLmgHya42gia
mZ+CIC0xp9H6OlJII1nOzF+Z194T02XcmXeJLR2S5ecABRAXTzPCtiMxv8VZfFGV
iRi8mvOuy3KZGYy3YOMD19yTFHc8IVsW3qFlDyEOMpDm4IjF5arYe6/I0ZDRL9qC
kapAId3qDqNYJ42QwEGkmmvcSYV0EPOoRzaHKtDCI9Wry4ZNS+M1uyvGImuF1Ies
wlgkCDJOBS76d60pnzXI
=yQBA
-----END PGP SIGNATURE-----

--=-aZG12+MvOo4q1l6Meo+N--
