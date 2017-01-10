From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [for-next V2 08/10] IB/mlx5: Allow future extension of libmlx5
 input data
Date: Mon, 09 Jan 2017 23:24:37 -0500
Message-ID: <1484022277.2149.4.camel@redhat.com>
References: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
         <1483890891-8767-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-8tHI/gS+mTj/g/byMq8Z"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483890891-8767-9-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-8tHI/gS+mTj/g/byMq8Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2017-01-08 at 17:54 +0200, Saeed Mahameed wrote:
> From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>=20
> Current check requests that new fields in struct
> mlx5_ib_alloc_ucontext_req_v2 that are not known to the driver be
> zero.
> This was introduced so new libraries passing additional information
> to
> the kernel through struct mlx5_ib_alloc_ucontext_req_v2 will be
> notified
> by old kernels that do not support their request by failing the
> operation. This schecme is problematic since it requires libmlx5 to=20
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ^ Typo



--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-8tHI/gS+mTj/g/byMq8Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYdGIFAAoJELgmozMOVy/dkDIP/0jyrB1QPac9+kwvEOxjwMy2
CtEx5K8HeURar83cM8SaJiM8rprX/c8Wbk//Dtbx0JOC7ze30ZmCcersFoIDp8yJ
zPzYgFD63SfEBmgwVDeakjBsPzBKBsZedKoJr6ivJkw9MJefzr094voXWvIDUxJk
cDcKivyUsdx5Re9YFqNAr5kZg19c+83+du6o/aeSf/vL2KtQIwz9jAwjqKHDqCYU
P7qxzxFdKw2Qi4n/xm6a4d++Y8P6oyF3uwC354dSQir7y943h6rmLvp8rQtamq5a
y5NTdHBbSTuichTVSV6aao0L7svMipuqxklps3uTTdq22Gi9PqNG44gYUv/jgeWO
Jvc6Sg8KytATgGoonPWatQSnphqTY4emcaQgOQlBZnYptmnuhraOiVlW4b0ysCEF
15FSI/L9fHWdAeZyFFH5XqBZOBPiv6zfq4Ioo8koTzGMeYZHqebhsmhw0dEE6D2y
C4Nqxxu0Tfh45ytKw9h06eep583cH+cLRdIUtS9GEtFZ2OdnZ4mjzW++9h0tYgcD
4ov5qStEqB/oHFdIlBkqORjunXT1v57WwKot9/rW/qwvK4lHQgGNoxWuaRTGu6V8
BRNSbUzqNa0VMhD8xhNJuDTTRnvJ71co/RIT/I+oAolxmsuZu4L/DMGT+ZyrEIMP
d/EROv2X1peqs2H2pph+
=sj2t
-----END PGP SIGNATURE-----

--=-8tHI/gS+mTj/g/byMq8Z--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
