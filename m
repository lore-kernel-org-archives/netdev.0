From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 16/20] ARM: dts: sun50i-a64: enable dwmac-sun8i on
 pine64
Date: Mon, 3 Apr 2017 13:38:47 +0200
Message-ID: <20170403113847.dca2tetjit7xoxyn@lukather>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-17-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="rszyeo3fyvj6idb5"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170403091444.29876-17-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--rszyeo3fyvj6idb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 03, 2017 at 11:14:40AM +0200, Corentin Labbe wrote:
> The dwmac-sun8i hardware is present on the pine64
> It uses an external PHY via RMII.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Looks fine, but please use "arm64: allwinner: pine64: " as your title
prefix. It applies to all your other patches (and the arm ones should
be "arm: <family>: <soc-or-board>:".

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--rszyeo3fyvj6idb5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJY4jRHAAoJEBx+YmzsjxAgSGcP/2dih+9STf4PFi4/dxayxv0k
Q07yqdVOImUZEdXENbX/kXK5ptvN+va1KWMpwFOdrhYzRSsn/4QjaqYZ0J8qYvA6
RxYKCvSmXGydlrtBZRL7Lf5piY+yBWPVKBFAIxc1QPjrVzPl2hA174gx7AAst/zU
J3Nc4cD6Epg+CLC+9ombPbtBI8Gc8PJehPx/FgaalGPSYHIgHsczRaZw3eY0cdgc
/0zTaTKlRo1kQaXaV6/QC/sT2L2WASbgk1CrpiuVYj0T7xFStBTrMw2Cff6T79CV
iAglY4gcGfWWbGB6UYz/G5vxfdZxOjG7Jm/zGgiPpfHw7YhqiF3P93z6RyGtI83w
zMhgPpJfyDOBWTH6Oktg/Ju3AK9QRyZvoL9144DWl/dg5jm/lg8ibtmcj9OsfnwO
rxUN2NB5VVdldNdM0qgmP6pX6yqFagW6642e88YPmd2v6dUr08tfKsCyXFHftHEC
8kzJtyThiGBH2b9Cf2AmkMX2quw+x1ngOnS9K3OqEQylHRgM7n8o9rPED23WjYxA
VJJ+PjF7EKms9GAUeDGme91KWrgsmyU3p5e8wxwxCwpd6O2mEtHOGAjV2SKzbfvv
ac41G7iriQx43juvHfwKVAFh9Tlv8wPgDMi29c4VJZ13QLt/C6XGY1EFKBbU3KOJ
cEySvH9CLJonOlV+INCV
=kh/H
-----END PGP SIGNATURE-----

--rszyeo3fyvj6idb5--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
