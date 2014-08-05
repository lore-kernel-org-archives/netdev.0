From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] drivers: net: ethernet: intel: i40e: Fix missing
 uapi/linux/dcbnl.h include in i40e_fcoe.c
Date: Tue, 05 Aug 2014 14:27:48 -0700
Message-ID: <1407274068.2436.7.camel@jtkirshe-mobl>
References: <20140805131143.GA29685@ttmp-linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-w+7SOWTOfwFo3C4HGqwg"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernelnewbies@kernelnewbies.org
To: Lucas Tanure <tanure@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140805131143.GA29685@ttmp-linux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-w+7SOWTOfwFo3C4HGqwg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-08-05 at 10:11 -0300, Lucas Tanure wrote:
> Fix missing include in intel i40e driver. Without this include linux
> next
> tree won't compile.
>=20
> Signed-off-by: Lucas Tanure <tanure@linux.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 1 +
>  1 file changed, 1 insertion(+)

Interesting that linux-next does not compile, yet Dave's net-next tree
does and that is with allmodconfig.  Anyway, I will add your patch to my
queue, thanks Lucas.

--=-w+7SOWTOfwFo3C4HGqwg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJT4UxUAAoJEOVv75VaS+3Os4MP/0VUUq9yL/0QSmQ0dgGiczf4
kVHg4KbCbSH6lcnGTOYxWiEdvY0avGMn6IRikXktXLf08OzVSCyMPfCIAZrmY18+
0MTX0a4Ifmfool2Pq1CItyeY5fQHLKV7KikSdPHewc0XT+0BqovvL6FRztJXLJVf
ij+dmJoBfmrKeisKiwPDso/DRhn4JLFLNmhayvWCc18mRj1ILrHeC3Y7x5il01ru
IApmkYp4GY4wAja0AkgrdLoSYnLioNve2GghvL4JLUigBZlJqt8nG8RKWdK5Rddm
/sHqpwwxbN7zWGP8HeOVXoRBrMqT38P7B0qBe884S6UkOosS+WCjUdP0b7fbgrOi
IKqWw0p2bwDCDV/XK30xCglEEX6oSC5JW9nQLirW8eEcJ1uTHjYiik0xB5hvLlrO
zY5pB1XpISLNMgCi5ISPhcLit7enOuNaIPnNpLREeKrtqzZB5eU+tQKEI/6xW1ZQ
NURG15x8ppKw47HBTxHxYLSLA1z+YZMTQUC3Z+xO/17TAH+aeEWgpZVrw3+dKqPd
KdQtuJJ7A41tJw27h4qFaOQ8VlsRZk/20FyVExx2b9LTKDbV83dM5o0+GzB/gfWw
h+16txfprqRDSUJWiq0tOxN3NQ1K5l4fSxVBhFf0h6BeukeIaiso3AUV+wQHzNn9
hCUhfuh/Ec1pvgV69L9O
=AQzR
-----END PGP SIGNATURE-----

--=-w+7SOWTOfwFo3C4HGqwg--
