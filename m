From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ethernet: Use bool function returns of
 true/false instead of 1/0
Date: Mon, 30 Mar 2015 13:28:58 -0700
Message-ID: <1427747338.2497.99.camel@jtkirshe-mobl>
References: <201503260524.AdqSbov9%fengguang.wu@intel.com>
	 <20150325215525.GA26868@athens>
	 <20150329.121655.2092434262655191613.davem@davemloft.net>
	 <1427678712.2715.52.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OlBWyRfrLdJoFjssSRgM"
Cc: David Miller <davem@davemloft.net>, fengguang.wu@intel.com,
	varun@chelsio.com, kbuild-all@01.org, hariprasad@chelsio.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ariel Elior <ariel.elior@qlogic.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	Michal Simek <michal.simek@xilinx.com>,
	=?ISO-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
	e1000-devel@lists.sourceforge.net,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427678712.2715.52.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-OlBWyRfrLdJoFjssSRgM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-29 at 18:25 -0700, Joe Perches wrote:
> Use bool constants as the return values instead of 1 and 0.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
For the ixgbe changes...

> ---
> > To be honest I'd might rather get bunches of these, there has to be
> a ton
> > of them, than a slow trickle of one every few weeks/days.
>=20
> There aren't too many...
>=20
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++--
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c    | 2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)



--=-OlBWyRfrLdJoFjssSRgM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGbIKAAoJEOVv75VaS+3OvasP/A8iqhqYf85z8SPiwNOEaSy2
qHeXlB+sa4Cz0+FkKOV5qCnMrtJDNrryyi60YNAAq7UB/LV9S8f48pn+JDW0KPQA
cuCSCeV6B2ZwaQ4awzC2XaZfwUNNleoYz/lpNGbOFcOUrLmGwgqc/uqDR1AJYVfr
OgYH5cGDh6Vh/KyHnI7rFHweJFrH/3QOYmWroprmh9qs+aFKA+R+ve+oq6P6JwhK
lFnwEaLeUfnw08CgzuRW61pBcXndrQy0hKRG0DvZMJRxqAa4IWAcgWFPZ4Y7hSLc
lMNwFAudgYYZ1C5VwU6eyoT+98ZdEpIC0fZ8uDGpsL/GTFaUgQHgWGuj6LTvCcmV
I/kj3YdCS966pqF92EMN7+I++wmEMYW5u6BPlas82OsGU53uW63bXC+qtpbG5Qtq
0aMtt75slKjIUNi1VIPJDdUROsojQs6Nqcn9rJlmlOfAOkIN7iae4ImL8RHRwKG5
ELaDAENs+rbU09VO7Sl9Qfx655nmjcuW1QHTqtXP1TdXHRcF8xLFr3aTe3hsoVAY
ZHPbzuVVLNfqYoHRQvMovQ1JVuHGziKDMKc3V+o55sjwOqPqnuqjPaeE86Ws7xRA
cDFUBQEEziAbWwkhlCIPknFkEAgL14RkphSFsufM6npyLhzawbzHRHZTQIo55KlL
uACVdEjDiBdORbHLs9LD
=B5ry
-----END PGP SIGNATURE-----

--=-OlBWyRfrLdJoFjssSRgM--
