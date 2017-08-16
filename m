From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH][V2] net/mlx4: fix spelling mistake: "availible" ->
 "available"
Date: Wed, 16 Aug 2017 15:02:31 +0100
Message-ID: <fa81af22-0a98-bbda-718d-e069287172fd@canonical.com>
References: <20170816134250.6689-1-colin.king@canonical.com>
 <20170816135851.GP24282@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="GaVcvxsP2jMV7R9CowxFf593bbo0g5rc2"
Cc: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170816135851.GP24282-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GaVcvxsP2jMV7R9CowxFf593bbo0g5rc2
Content-Type: multipart/mixed; boundary="FGbPQAqjbJ9o03QWvfbHAlED6UcooGh3G";
 protected-headers="v1"
From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <fa81af22-0a98-bbda-718d-e069287172fd-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH][V2] net/mlx4: fix spelling mistake: "availible" ->
 "available"
References: <20170816134250.6689-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
 <20170816135851.GP24282-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
In-Reply-To: <20170816135851.GP24282-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>

--FGbPQAqjbJ9o03QWvfbHAlED6UcooGh3G
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 16/08/17 14:58, Leon Romanovsky wrote:
> On Wed, Aug 16, 2017 at 02:42:50PM +0100, Colin King wrote:
>> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>
>> Trivial fix to spelling mistakes in the mlx4 driver.
>>
>> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/cmd.c    | 16 ++++++++--------
>>  drivers/net/ethernet/mellanox/mlx4/fw_qos.c |  6 +++---
>>  drivers/net/ethernet/mellanox/mlx4/fw_qos.h | 10 +++++-----
>>  3 files changed, 16 insertions(+), 16 deletions(-)
>>
>=20
> What are the changes between this version and previous one?
>=20
> Thanks
>=20
A fix on "Availible"

-	mlx4_dbg(dev, "Port %d Availible VPPs %d\n", port, availible_vpp);
+	mlx4_dbg(dev, "Port %d Available VPPs %d\n", port, available_vpp);

Colin


--FGbPQAqjbJ9o03QWvfbHAlED6UcooGh3G--

--GaVcvxsP2jMV7R9CowxFf593bbo0g5rc2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQI2BAEBCAAgBQJZlFB4GRxjb2xpbi5raW5nQGNhbm9uaWNhbC5jb20ACgkQaMKH
38aoAiYdYhAAom/ESTLZdedEayVImdIEVv04VLcSn8Rqd+uj7EGDJcQNriLk8bi8
0tGNOZO/YadvoFF8O4LASrcW+F7bBHK4Jv/pWig6dZ4EWVXkEyN9SX6XJwi585V/
SVETLxMXn1YkZQWboKgYZQoCj0SpCQZmfG8uGsLGtXbJ9JGaycItxdvCatY/ivC1
WOvQT1Pm0q88SZPE6eP0noKkeRXVjADlF9vshZZsnC9/8kIGt9wzyEqN6Z7fZsbx
0u7kQtywkKiUWX8MhtFuNizOf4cjNRt5IoRme4fLi6kzpzkSdm4VLtfIHCnLJMdz
zqXWvSOsscy8RQwelWnAZAco6uCVQzChsGPzoq75asSegkBFvtcP4y14Knonn4hw
3yG2t6clnYh1qEmAIZqYqb7woVhPZZ2/KkDnD0SCJVDH3RpNp2w4v05kQHWmqPRb
Ug4yaIqdHi/C4ApgzyBvgIrzD8y2ANSRSU2kw5Su7XngAUDG1+cGFwukIgE2/iOk
0EMh+CRQB/UeruuieiieAxKsLdwy4d7U86TvKGZLITaGvwBLbFjL0rRU43MCGLKK
kvAEzHZKV7/44J1ZEsVeUmFf0wj9lwt2lPZiHgP74Sqn2hW6ClNcFT/hLGU0+3KV
e8cUbOttilmCFqooO8e+V2GGTBD0yQ1XTi3dGMlEr3hQz7ytPGly3Ok=
=Muas
-----END PGP SIGNATURE-----

--GaVcvxsP2jMV7R9CowxFf593bbo0g5rc2--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
