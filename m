From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/1 v2] net: i10e: use matching format indentifiers
Date: Wed, 10 Aug 2016 10:50:48 -0700
Message-ID: <1470851448.2128.15.camel@intel.com>
References: <20160731.204759.1283451349474511870.davem@davemloft.net>
	 <1470161718-8824-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-h96oO27GaYc45A6+VWZP"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470161718-8824-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-h96oO27GaYc45A6+VWZP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-08-02 at 20:15 +0200, Heinrich Schuchardt wrote:
> i is defined as int but output as %u several times.
> Adjust the format identifiers.
>=20
> v2:
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Keep definition of i as i=
nt.
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0David indicated that this=
 is the preferable way to define
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0loop variables.
>=20
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 26 +++++++++++++--=
-----
> ------
> =C2=A01 file changed, 13 insertions(+), 13 deletions(-)

your title needs fixing as well...
s/i10e/i40e/ and s/indentifiers/identifiers/
--=-h96oO27GaYc45A6+VWZP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXq2l4AAoJEOVv75VaS+3O32kP/RE9ABGsEfLF8ZpbSw3OXwWt
CiA6F/NZWGTF/TdCcbov6DH9PXqdIxGzmlXlBePS1hNlEHF69+ScqQMW1f10RfDN
aIfN6872tnwO0C00klnAQNOH+lrbvzLYjIkNo2qY1/1viAezoBONPU4DmlKSLjfS
xKtW4fhGdynFzaV6IP4ZASkIb+YwQFXBZhNswlmCz/U1q5XqAxBZ5fXfw2Bj7gtI
QtPHkEIe1RWKfDS+VLN2Uwb35R5A05Rfq6W8R/EPDpP/9mFj7c4cxCav+3j9+eVH
X52qymIFbxWoq/Ub2fZhqXhl+yCcT1GYE369PDeQYxW910ap7ldFZhGCBVlUAydc
u4fZrDebaKmAQU+kK3IQjwFWWoVvYkHTHDP9VYPDaDzRfqyXToQgisjknkUukCkx
jyKNR+zSNCFNTM5ayNQDsw/256xm0Z23Qht7NHMCnyDMMR2wLBezTJTzCHJ/DLaE
iCiT6IuZwXly0oO8fpKMXj0ug0BNmQ2sb1aFJ1Cvu+bkINVU5dt5VsnNO4zQR+JP
uOFDCGhQ/M1CJsxoxrWn7YAq3i+wcqLLKionI11ncD9RrBXuamDyTTtuq8Nxdhwn
kM/UGxl/tjY4vDFsCz/gFE5KitkWAsmtNVxEnaPfzMt7FIMmV6ztpfj28CXSCf8K
SMFBAfLbsWU7HnfO8Ahv
=TGI7
-----END PGP SIGNATURE-----

--=-h96oO27GaYc45A6+VWZP--
