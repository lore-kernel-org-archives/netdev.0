From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 2/4] e1000: advertise transmit time stamping
Date: Mon, 23 Jul 2012 01:18:41 -0700
Message-ID: <1343031521.23226.29.camel@jtkirshe-mobl>
References: <cover.1342976654.git.richardcochran@gmail.com>
	 <33885adb6b0e97e6b21fd1903fb6ede3ed7b50ab.1342976654.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hJm7WU5kXU4OvdPfMeWj"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	e1000-devel@lists.sourceforge.net
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13254 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980Ab2GWISm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 04:18:42 -0400
In-Reply-To: <33885adb6b0e97e6b21fd1903fb6ede3ed7b50ab.1342976654.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hJm7WU5kXU4OvdPfMeWj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-07-22 at 19:15 +0200, Richard Cochran wrote:
> This driver now offers software transmit time stamping, so it should
> advertise that fact via ethtool. Compile tested only.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>=20
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: e1000-devel@lists.sourceforge.net
> ---
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-hJm7WU5kXU4OvdPfMeWj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQDQjhAAoJEOVv75VaS+3Oe6QP/1OtFbzwbc1edKvSw0FYuHBH
KUuvBT74d43wpHjZfe7ZGFKmkjdGwi3la+5fGbCdawu1KXHS79NvEuuG4kaKA3SU
cI6FDKFU2BfPMNFvYZQ4Hrr5eOxWXFSmFHC0WP290sas9L2oGZ+TNZYhj3mULycB
fKSFC/wUskFCzvCre5Jp4pRJRpjUOFdmIXgklBHE8Sdq2bXOWhV9FeU8XSJH1ObS
XrxpbC+Apj4IUxUyVlA4q002kIuPtmBkXAC/4nW35zJuR2mu3bt5mOWRapisXjzQ
lGLgur3qx7pY4qpQKnWDvuF4IL/giM13/2BJJnhcaMQsUzlvMyM2qb98ndeG/ADi
CjFwP7iXbdcrLZp4jgi/cKvMrY/11QVbo/6IesivsgliiVyC6mEIVJC8fOV/m8b8
y6VLL9beJVP5YFFmkwxwe28ccsrXlWHicuKuqOQbA+YFIz/lTSAM+T7ZY76OmCeF
BwqiRU5QUsReBuU35fH9ekjPgv5s/PYr8YIMos/WUHVJl27W+KwmJEXqa9pOkNPc
4SYVuY0yWK/MQFOAkX45EPi+yKoSyqBsIQmOIkpsWnuq4Us3FG/jVr8NOsKlFCVu
AjhAyLAtwMVP+EvrxXHXqxr8b0ylfHF9Aw4Xjs00MlS0syUqgiGp696MSVCZ20MU
RWlrcF1IUZHbqc/+oh/h
=W9XF
-----END PGP SIGNATURE-----

--=-hJm7WU5kXU4OvdPfMeWj--
