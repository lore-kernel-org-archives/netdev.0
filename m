From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH] MAINTAINERS: Remove myself from PA Semi entries
Date: Wed, 14 Sep 2016 02:31:57 +0200
Message-ID: <20160914003157.GA1420@katana>
References: <1473803318-25197-1-git-send-email-olof@lixom.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: Michael Ellerman <mpe@ellerman.id.au>, netdev@vger.kernel.org,
        linux-i2c@vger.kernel.org, davem@davemloft.net, jdelvare@suse.com
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:43388 "EHLO pokefinder.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932633AbcINAcH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 20:32:07 -0400
Content-Disposition: inline
In-Reply-To: <1473803318-25197-1-git-send-email-olof@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 13, 2016 at 02:48:38PM -0700, Olof Johansson wrote:
> The platform is old, very few users and I lack bandwidth to keep after
> it these days.
>=20
> Mark the base platform as well as the drivers as orphans, patches have
> been flowing through the fallback maintainers for a while already.
>=20
> Signed-off-by: Olof Johansson <olof@lixom.net>
> ---
>=20
> Jean, Dave,
>=20
> I was hoping to have Michael merge this since the bulk of the platform is=
 under him,
> cc:ing you mostly to be aware that I am orphaning a driver in your subsys=
tems.

Let me answer for Jean since I took over I2C in November 2012 ;) I'd
think the entry can go completely. The last 'F:' tag for the platform
catches the I2C driver anyhow. But in general:

Acked-by: Wolfram Sang <wsa@the-dreams.de>

Thanks,

   Wolfram

>=20
>=20
> Thanks,
>=20
> -Olof
>=20
>  MAINTAINERS | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index d8e81b1..411f4f7 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -7155,9 +7155,8 @@ F:	arch/powerpc/platforms/83xx/
>  F:	arch/powerpc/platforms/85xx/
> =20
>  LINUX FOR POWERPC PA SEMI PWRFICIENT
> -M:	Olof Johansson <olof@lixom.net>
>  L:	linuxppc-dev@lists.ozlabs.org
> -S:	Maintained
> +S:	Orphan
>  F:	arch/powerpc/platforms/pasemi/
>  F:	drivers/*/*pasemi*
>  F:	drivers/*/*/*pasemi*
> @@ -8849,15 +8848,13 @@ S:	Maintained
>  F:	drivers/net/wireless/intersil/p54/
> =20
>  PA SEMI ETHERNET DRIVER
> -M:	Olof Johansson <olof@lixom.net>
>  L:	netdev@vger.kernel.org
> -S:	Maintained
> +S:	Orphan
>  F:	drivers/net/ethernet/pasemi/*
> =20
>  PA SEMI SMBUS DRIVER
> -M:	Olof Johansson <olof@lixom.net>
>  L:	linux-i2c@vger.kernel.org
> -S:	Maintained
> +S:	Orphan
>  F:	drivers/i2c/busses/i2c-pasemi.c
> =20
>  PADATA PARALLEL EXECUTION MECHANISM
> --=20
> 2.8.0.rc3.29.gb552ff8
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-i2c" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2Jp8AAoJEBQN5MwUoCm2Up0QAIY9lV/dJ5rGJ2Yif7jf7MWt
KDl35qc2kdtjxoXJoXh2iyyVKDEG0RK+QWFr6/oMq1BW0N/Jhy+xFQYAZo1Hy91K
4w+3vYHIokcoeeLWLyoTAEdZsMD0PMdcchwlRb2+bc410rdfFf/O6b9BRYh1HWul
7fIOA+F4EO5obEaGGPTjylMoy6n693N3O6rVgUJQkA4IFsys9LVXsBtn/Ia1t+wV
QIsLm5gOHiNJbrIqSxmbmJzD8VuxV+crnS2M6eNQ3kCedLZStiUr+V02hkoRp+t4
o9eCuCpzdnmxmcSRDhhFoax8VbX4vEax7T+9mWNRXrxGgYTa723yzzGLfg27Q1JE
brZxbnG43ZFW45WGsQFS0IZIN3XW4xxaH+fXIcDSChEbX4D7UvJ8hX3utQXQqSZs
yU5SRxwx738uVJYoRo9PqD2dlcP52utclIlm2rcfR0Zs0mlVaeJ0KJvvbRtAFe9h
+wD3d4MnYs9WRmQblFfmg55IEL00FlyZps7pDd5hxyKALh7Fdsl5sE2WRr4STsis
2FUrIk8q+h0LV4sVDjuoeF4AIuPmQGecUJz8PANC0VpFh+zZr6DkMCkm3hbeyy5e
njf7CPr2jroSXOcbPr0nCzyEPVdqBFpGUL/SPO7dVyuIRaSguJwYWy1YpHgQ68ZN
uIpM45WrHqDavHR984Xv
=x6MH
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
