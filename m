From: Ben Hutchings <ben@decadent.org.uk>
Subject: bnx2x firmware version 6.x.y
Date: Sat, 17 Dec 2011 16:52:26 +0000
Message-ID: <1324140746.2825.335.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BRW11N11I0lwHUfZjHFt"
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42355 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752359Ab1LQQwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 11:52:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BRW11N11I0lwHUfZjHFt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

In general, linux-firmware includes all blobs that any released version
of a driver may need.

Therefore, I'm about to add the bnx2x firmware versions 6.0.34.0,
6.2.5.0 and 6.2.9.0 (taken from kernel versions 2.6.37, 2.6.38 and 3.0
respectively) into linux-firmware.

The full lists of bnx2x firmware blobs that will be included after this
is:

bnx2x-e1-4.8.53.0.fw
bnx2x-e1-5.2.13.0.fw
bnx2x-e1-5.2.7.0.fw
bnx2x-e1h-4.8.53.0.fw
bnx2x-e1h-5.2.13.0.fw
bnx2x-e1h-5.2.7.0.fw
bnx2x/bnx2x-e1-6.0.34.0.fw
bnx2x/bnx2x-e1-6.2.5.0.fw
bnx2x/bnx2x-e1-6.2.9.0.fw
bnx2x/bnx2x-e1-7.0.20.0.fw
bnx2x/bnx2x-e1-7.0.23.0.fw
bnx2x/bnx2x-e1-7.0.29.0.fw
bnx2x/bnx2x-e1h-6.0.34.0.fw
bnx2x/bnx2x-e1h-6.2.5.0.fw
bnx2x/bnx2x-e1h-6.2.9.0.fw
bnx2x/bnx2x-e1h-7.0.20.0.fw
bnx2x/bnx2x-e1h-7.0.23.0.fw
bnx2x/bnx2x-e1h-7.0.29.0.fw
bnx2x/bnx2x-e2-6.0.34.0.fw
bnx2x/bnx2x-e2-6.2.5.0.fw
bnx2x/bnx2x-e2-6.2.9.0.fw
bnx2x/bnx2x-e2-7.0.20.0.fw
bnx2x/bnx2x-e2-7.0.23.0.fw
bnx2x/bnx2x-e2-7.0.29.0.fw

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-BRW11N11I0lwHUfZjHFt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATuzIy+e/yOyVhhEJAQpc3w/+OtbqGI5ySzbR4wrBSXmglmpr59RV4i9v
bRt/ro5mbbL+qSpNzG5wy0btjzvFSsbDUtKpmdFtmNaLDS6mwHvSg2CmkvWV1Lto
Oxh8NV1aAyeMCH1yfokDw11QDsBVOFFhJUUNoR5Ye/fDP2+HcqbBmt8Pm+4Cy48S
NdueOkAkGKut2X6xVEUerR3pNaNkig13hCR71JQxM5D+jB78ajyt9861kHelEWYC
AUxluzzOydqOPdb0rrvsgsJqHB2Oo8SrfSk/zIzQ7mmTNy0QLfTysTUYWIjL9OYE
Gx3X9zKo5e1fdplfIyRIqJXjMS9xpaOPH4yw+SNnAlcC6ozOJ3sWT0KfJD1gO41R
mwJG0lP9cUlupk5HhvYQEV+2AZFsjWW3AoEjaPPdUMF6ki6j1I93gg5b06EucIpw
61vRmzCkTiXNmwSCi69wJEV6aHrZUudjdNhv4kwZ9oEiiBnCkhgvQR1dhpk3CTCt
OX7sP5qY+xACP3qIAiQWpRNMVd4tP964rFbxk6hT56nGcqOmnxJHDr3BqqMtgvjn
wOVoTd/1T+hYcJ/T0Et6eEs22ARxIaFKSzLzGficEchKB71HflPTB7d7bO6HRxvh
wi2a0SLVl+06jOrUt6VE3soadyVRm6Sx0Q1yG1l5YEm8e4vONJSAD0ZQOEsviQqZ
+zXnIW51lcU=
=w6lh
-----END PGP SIGNATURE-----

--=-BRW11N11I0lwHUfZjHFt--
