From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] checkpatch.pl: Fix warnings on code comments
Date: Sun, 27 Jan 2013 18:56:45 -0800
Message-ID: <1359341805.2255.56.camel@jtkirshe-mobl>
References: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20130127.185910.1743425400733006443.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jnZJKtJ0IFSVZHuFDFDq"
Cc: apw@canonical.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130127.185910.1743425400733006443.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jnZJKtJ0IFSVZHuFDFDq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2013-01-27 at 18:59 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 27 Jan 2013 03:35:39 -0800
>=20
> > Produces warnings on code comments which follow the Linux coding style
> > guide.  While the desired code comment style for networking my differ
> > from the rest of the kernel, both styles should be permitted.
>=20
> I was actually going to mention to you guys that I've been lackadasical
> about enforcing the comment style I want with the Intel drivers.
>=20
> That was a mistake, I should have enforced it strictly, as I do for
> the other drivers and the core networking code, from the beginning.
>=20
> And it's clearly a mistake if you feel the need to take out the very
> checkpatch working that's meant to enforce this comment style in all
> of the networking drivers and core.
>=20
> Do not revert this, follow it's advice instead.

Ok, I am fine with that.  I just had not seen any emails/responses that
this was direction you wanted to go.

So will you be fine with cleanup patches which go through and convert
all the existing code comments to the desired format?  If so, I will get
started on patches to cleanup,convert the Intel drivers to the desired
code comment style.

--=-jnZJKtJ0IFSVZHuFDFDq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRBejtAAoJEOVv75VaS+3OrUcP/iSx54sJ8HvI+s9DTU53nwa2
fLPmNpZX/A60881vrHgzlM13HplijRcz3rmOsMc8xAgTVwEHoeKm/GXLJvU/nk6j
QNHo8hbPowx0kxQ7BjAE6JNnfYCkreNM6v1jrzP5oMc7VO5slKX7ppotzbUQS99E
oin6lzKnM+AzLgpmB4NbZ5rWgVjMRg63XtvKu7VJdZhpEl4m2xHn9aPIdUN2jr6N
orChCUmWfiSWEsjKnGIHBYtZw1m5zlxFUqZIN3CF3Rha2nGrO2u/oaGiRbsLf2mI
FnOaFBYDFcgNX5dZijr9LvXfFSEDFxjSRUiuzSGEZcWi59HexIJQnywXefiSxpi4
XF+y3Bbz6oxh7uB3wUNbyQl2CRf72HnLmkYDVQEGca1fWdW3Itnthf0aeZhOYneV
rgo+u+r4yakOIDyzJ6rpthiIBQNCCl0vHwGcOhoxSSy5v1PFJ6x9lmOav09e9n0i
4uNmdCBl6aODzBan8l10QTVPP6HbHjBfOP9V50B4zHn+KwFQB+/cmBepQ3uvosp3
FMSO0kALZn/wQ1ePIl++2KKys2Cto6NBIKdXCUAMq7PiIYaLChSBgQIkI7J7YGQY
tOQ7QToQZIOO91MNWkIHZ7WPleEKdCthHfmP8HNRnUkpZHkECJVoo4L7sR+Eu7GD
u7TjKOtiVoLhFQRf9paF
=U86d
-----END PGP SIGNATURE-----

--=-jnZJKtJ0IFSVZHuFDFDq--
