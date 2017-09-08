From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 4/5] Add KSZ8795 register definitions
Date: Fri, 8 Sep 2017 11:21:12 +0200
Message-ID: <20170908092112.GA18365@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A8E@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:34287 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752047AbdIHJVO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 05:21:14 -0400
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A8E@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2017-09-07 21:17:27, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
>=20
> Add KSZ8795 switch support with register definitions.
>=20
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/drivers/net/dsa/microchip/ksz8795.h b/drivers/net/dsa/microc=
hip/ksz8795.h
> new file mode 100644
> index 0000000..005eda5
> --- /dev/null
> +++ b/drivers/net/dsa/microchip/ksz8795.h

We already have ksz_9477_reg.h. Please make it consistent.

> @@ -0,0 +1,1015 @@
> +/**
> + * Microchip KSZ8795 definition file
> + *
> + * Copyright (c) 2017 Microchip Technology Inc.
> + *	Tristram Ha <Tristram.Ha@microchip.com>
> + *
> + * Permission to use, copy, modify, and/or distribute this software for =
any
> + * purpose with or without fee is hereby granted, provided that the above
> + * copyright notice and this permission notice appear in all copies.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANT=
IES
> + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
> + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE F=
OR
> + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
> + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
> + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT =
OF
> + * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
> + */

-ENOTGPL.
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyYQgACgkQMOfwapXb+vJ6hACgjwtgOFTVoLI5qtXb6b+4rj24
vrQAnA97/M58w5/WtZ/1k94btJJttwHA
=nKpt
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
