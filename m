From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH firmware] rtl_nic: update firmware for RTL8168G
Date: Mon, 18 Feb 2013 03:28:49 +0000
Message-ID: <1361158129.5374.549.camel@deadeye.wl.decadent.org.uk>
References: <1360163939-3625-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2knzy+UWkxXKFSVKbYGe"
Cc: dwmw2@infradead.org, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360163939-3625-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2knzy+UWkxXKFSVKbYGe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-02-06 at 23:18 +0800, Hayes Wang wrote:
> File: rtl_nic/rtl8168g-2.fw
> Version: 0.0.1
>=20
> This firmware supports new fw setting mothod for linux kernel.
>=20
> Add MAC OCP settings for:
>  -phy reset
>  -PXE in ALDPS
>  -pwron sequence
>  -OBFF
>=20
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  WHENCE                |   3 +++
>  rtl_nic/rtl8168g-2.fw | Bin 0 -> 4896 bytes
>  2 files changed, 3 insertions(+)
>  create mode 100644 rtl_nic/rtl8168g-2.fw
[...]

Applied, thanks.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.

--=-2knzy+UWkxXKFSVKbYGe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUSGf8ee/yOyVhhEJAQo2EBAAzYdoqoC5UJiUSonz7zWzuAxAlDahC+3B
Y972U4Vw54CUnGOWagCLXojdAJUNdmdWvIJnfjkIrU4nC03I1NGOtwNiFrYQhmI1
q6rO/SpxsE1gGkvvtjjtlB8FDzMPgFLpS739TUwHxTEFi1qsZ1vP5+ajkiMiNkLX
Om5QCEjBDr7UIXvj4jKdzt2RQUFrTW9Gu5j8wdVTmU784ZSkCVtcO86j4l9sFgJ6
1vyU0LDej+Lzp75INOUPgmSRf7XrZdNihc1RndSP6ZOpa5oysq1wR3LQ/ihzfAa/
zQ9MW2+d+PnXrFh1BCPPYRa6zmDYHvDxunEy8gJGxR6rvs+ztVHhvJB/mNnldm8g
XHS+tO4fUmQoWz6TW5/udEpC29SQA6GZDogFk+Jw7FHthbQ56ZHRsHlfSsPCjvkd
+G2HOlSowslnGdQglzO+K/dGwwl0p7+yOdQASn1shlzuC4z83Mb9IGdnyf8AB+tz
WTkhWvVlqL+V2RsQLm3SiEU7djMjTRCwWI4yTl3r2RzNL7TqmVdSvVkQlmpKE9v7
DpHm/W90gkmy5sL7NkdJeiHGgvJVTMj6ZXFi/TPEXpEslALclvAauxEbx7qZOd6L
U35SF9xzYhco7n4jzE24/WxjT6KMzaC8N0pk7FJ5Z/1MiacEPRbDbfo8G8v//bvo
puzPKyc8BgM=
=6iMV
-----END PGP SIGNATURE-----

--=-2knzy+UWkxXKFSVKbYGe--
