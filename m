From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net-i40e: Replace variable initialisations by
 assignments in i40e_vc_get_vf_resources_msg()
Date: Fri, 08 Jan 2016 02:42:50 -0800
Message-ID: <1452249770.19358.34.camel@intel.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	 <56868E0B.5040602@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lN5SgUWDmEYPt25O9lRx"
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <56868E0B.5040602@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lN5SgUWDmEYPt25O9lRx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-01-01 at 15:32 +0100, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 15:11:09 +0100
>=20
> Replace explicit initialisations for four local variables at the
> beginning
> by assignments that will only be performed if the corresponding code
> will really be executed.
>=20
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 15 +++++++++--=
-
> ---
> =C2=A01 file changed, 9 insertions(+), 6 deletions(-)

Dropping this patch based on feedback from Shannon.
--=-lN5SgUWDmEYPt25O9lRx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWj5KqAAoJEOVv75VaS+3OGMwP/0F3ODML8eXK6HdmMVIPwGR5
qIJv+5c0CBIPcRBEfT9OhMgY1b2To2GYBIvE4PXoDzPF7IhpB89ekSjXRehn06Qg
J3rlRh+msCzGYNLrGh1a92MfsMHAi91g2U/WBLEyrnkyP+W9Vvd9AeYczyEz/IEs
7VdDZqQ68uRTUj6VaExjhowMgJxXps/GHbLelZrOYrskLam1cXofqJCNLMcIAZdE
SL6PNPV3vOKThOvUfoxokVvPrTEONsyn/QdBhEJiatwMXiyAc/fssBUH//9GbeTA
dmVgbi6hPz9PqgQuIrLC6HCmYB/++JWCcNxvwe/bpVeR6Wh/j4dN52KJTwLE9RbQ
FIcE0rMBDq3GbFvLKo73BlL8afMSyNvBwunmPJkBdKcPIVB8F5sKlnPi6GXWPN0E
f8+RaiWNT341d7a9jL9BtD5OQSBh2QeY2nnoe5bIR0owNHB/gX4J+TDfBVEJt1jH
YLcUKCoCZ7LPghu5ykR3oZEBxb2Uj9m9qplrIkktrzkNBiYW2y3rofPy309zMIkJ
Zg8Eajlj4AhAyMRreJ/VPCjkp4Ch48ZX+Io1hrKJIF+x6BM/Kv/XE7Nx0bC04urR
6/fuAjryJMqsz4PryVSZi2uOwCN6FXOmBrTxo3QS3vj0NWMA7pQHb7yRUE01tMF/
VgkDG0wm9ReUad16AjLx
=1Uqp
-----END PGP SIGNATURE-----

--=-lN5SgUWDmEYPt25O9lRx--

