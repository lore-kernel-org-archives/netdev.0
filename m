From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 0/2] Part 1: handle addr_assign_type for random
 addresses
Date: Mon, 02 Jul 2012 12:23:32 -0700
Message-ID: <1341257012.1987.2.camel@jtkirshe-mobl>
References: <1328816934-11508-1-git-send-email-danny.kukawka@bisect.de>
	 <1328818164.3639.15.camel@jtkirshe-mobl> <1341255355.2750.23.camel@lorien2>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-h+bkIv7LmP5Hq7QsdV/3"
Cc: Danny Kukawka <danny.kukawka@bisect.de>,
	"David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shuah.khan@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341255355.2750.23.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-h+bkIv7LmP5Hq7QsdV/3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-07-02 at 12:55 -0600, Shuah Khan wrote:
> On Thu, 2012-02-09 at 12:09 -0800, Jeff Kirsher wrote:
>=20
> >=20
> > Thanks Danny, I will add both patches to my queue so that we can
> > validate the changes for ixgbevf and igbvf.
>=20
> Jeff,
>=20
> Which upstream kernel did this patch end up in? Also did it make it into
> any of the stable releases?
>=20
> Thanks,
> -- Shuah
>=20

It looks like it was accepted into kernel 3.3.  I am not aware of any
stable kernels earlier than 3.3 that picked up the patch.

--=-h+bkIv7LmP5Hq7QsdV/3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP8fU0AAoJEOVv75VaS+3OwDoP/0FEP18HiKfht7IwkReesmc1
4kmMjrPQesbdK/bfjVko+sVQEaIGmpJEhf424gqPRbGQWNmYBSmwOUS29PWsG351
jzbJA1iFUC/FX5QcM4foJCrONC9ztsIbXJtZ9NysEUMrScpFoabkjm2wgtQzHcHZ
x8X1m6f0IdTGFArgTU+oiVTUVMIwTH1BhQnKPDtJtymTn9l5DYm5iyGNV0W1pE56
0WyFN7YAJ94ql8vxjepxzvkDOvB/Z40cDuecPl6sWEUIRUau6zu4fuwSApeI+qNX
SMB3CS1oWbuvmjcOiAp2uMHldP9vmjBnAfU682NM4ZGSezjCD6sgsBjCH5Yk9JMZ
qG1NDOMobCDzMaiB8nwlOQpNqtBjT699nLqxaAqdRusVsR0hpa9sW/9rizjGxd9g
nMyj1JKK/wpU8nxcF8+WkdTD7srT8L7Tjzkbgur8cuNQdykq8aTtlnrgH1lh0mgz
5S8AjpXl4BxRi5mD0E6iNgrEZt6nfOD409i1f7QiejR4wsWrN5ykfX99+B8LzQKT
tWjHHeRZ/u+udXLohBngegbtAVo8ceCky07O8virwrfGOuzW0bi2ho5VLdFsXZhT
DgwOMKSRu1VDpnzoz/EyquuQYgzLI+R+bb5REYmI1yqz/S018eyCY1EoDYb+OVpD
ECp+P99zG3ga/3kuhFMf
=Mfp3
-----END PGP SIGNATURE-----

--=-h+bkIv7LmP5Hq7QsdV/3--
