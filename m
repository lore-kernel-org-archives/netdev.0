From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [patch] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Thu, 14 Jul 2016 23:09:38 +0300
Message-ID: <20160714200938.GB30603@leon.nu>
References: <20160713100825.GD29468@mwanda>
 <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
 <24af412f-7fa5-fa2e-c605-21ea5d45f5ff@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LpQ9ahxlCli8rRTG"
Cc: Matan Barak <matanb@mellanox.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	<netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <24af412f-7fa5-fa2e-c605-21ea5d45f5ff@mellanox.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--LpQ9ahxlCli8rRTG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 13, 2016 at 02:40:26PM +0300, Or Gerlitz wrote:
> On 7/13/2016 2:19 PM, Matan Barak wrote:
> >I'm not sure EINVAL is the right error here though.
> >Maybe -ENOTSUPP is a bit more appropriate here.
>=20
> I agree, Dan, can you please change to be along Matan's suggestion?

Or,
Dan already did it before Matan's response and we have very vivid discussio=
n about it [1].

[1] http://marc.info/?t=3D146841063000002&r=3D1&w=3D2


>=20
> Or.
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--LpQ9ahxlCli8rRTG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXh/GCAAoJEORje4g2clinaosP/0MTZ7lmSza7yuR3+sz0uzsL
5WQtQg7U8drKjhmSJdHIZtFTIuQezhuY4dWv+jcrHJdEF7woT6zofSadDZQKe3q5
KyWyQnA74DbKMG5+TQORhzvhDTYu+Jq30JyJni1AOzE4E4B/qRiNBhdOHuETe/xq
MYMEW/gE7IK4WcLOaCJneFmGy0WUuSDtY1DkFnPv8NKdUmWRcIisiZwMLqo+JH6E
CAbL35r/31nvpWJxI4iZygI+U1gQDGCckYIbe3SGSJgsVVD9ntnX0xTTZ/S8Su6w
vuLDK2YNlw/XoncABNCBvAyrb9K3QWx1+/R8WQ2F0pumtscFcZ7UX8vFgOOk5jqH
5RzPYkLhvKlL4QarV/tD1rOLv5PvqQi9jQi5bMNiuPiwH5c6UM/S3+PtsyyMe8CE
aUtDOQ2wBzQw/HVNY3X0cGKVFNIy398ipxqyN4kIor+CNz3A2UzLHCaO7eWjWUrU
WZvP2ABH4/Bkn6RmHUOIkJGqakLTdKEKep3gFwKiiLTzRbeY+pHlsRinRhA3eAzm
Y5IL25eYneg/ZsTNwIOEqw5ZIib3WknjodkG1VCcXSypNe/fAZKPrbTBiNUySIOi
67hBZoXW56CSy1Opn9zlOqDQ5mn5tOe2IGZYxOdvLLaLR/JxvsVABVaOKbxCEhhR
ZySNjb8RBWpOOnf1oF9Z
=gkxV
-----END PGP SIGNATURE-----

--LpQ9ahxlCli8rRTG--
