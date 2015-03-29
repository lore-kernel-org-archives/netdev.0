From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 56/86] intel/ixgb: use uapi/linux/pci_ids.h directly
Date: Sun, 29 Mar 2015 16:55:01 -0700
Message-ID: <1427673301.2497.83.camel@jtkirshe-mobl>
References: <1427635734-24786-1-git-send-email-mst@redhat.com>
	 <1427635734-24786-57-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nSsnmmYklwyfpO19TtBs"
Cc: linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427635734-24786-57-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nSsnmmYklwyfpO19TtBs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-29 at 15:41 +0200, Michael S. Tsirkin wrote:
> Header moved from linux/pci_ids.h to uapi/linux/pci_ids.h,
> use the new header directly so we can drop
> the wrapper in include/linux/pci_ids.h.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_hw.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Michael, I will add your patch to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-nSsnmmYklwyfpO19TtBs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGJDVAAoJEOVv75VaS+3OXhUQAI+ulVIaddEoeD+Vh5Qz22f+
NuD9iYTpnHikL9Bkap4wD9Vwyf1loWICpjavVYEwxHQtuzg6/0kYAaIeyv1aVcma
8nLyqoq6hmtLwhE+kC8Arkr5ehSgsc8WWNtgLeJId7CE5S6XO2Ii9NUpgcskzbBq
5v8N8ahEV9tPBKK/nmpV66PSAmCuWqWl/Mu85AlwSQz9+6VPEhE4lbIAjurCkrD7
7MOR4iQC+3wBpxnujk6Zh3hpk8WpLCEVptbKFRR2XZR/iQDTPj9DBTB1143aMj22
Zt8TA9jq/xMLpwVjdQ4f/rKU/ZDJVH+UtSRCc8k+sCuqRhCin8oilyIhoneldibY
8j2GbYrHoWu937rU0Ae7ZUDDxkHuDvm9sCXu9WboF701OTDhGBm/UTXYDai4xXx2
pAqOXA6digB1S3PHQ1Zomz7nkpvrwuDLsnR/uDcmc9DT1jSv7sODsCh451X/VSiT
PWRPmGpvs1/gj1FsLBYpwWjbSOEf/3dR/JqM79gcFnomzGlUlWhlqFBYSDgfamDI
yTpF/GJTi2yj5G/EuXQV9V3iuYaPnG0PPrPW1BKdyeCTcSqI097yt6+nDn/hiRAt
h8ChlyM0si4zEkxVroegvYO5OJaL4VREM3ptwhvdDYb1TwhCeHl9seMRsxS/UZF5
Bi5D+yxSMpa1e2hNKKWn
=Uk/K
-----END PGP SIGNATURE-----

--=-nSsnmmYklwyfpO19TtBs--
