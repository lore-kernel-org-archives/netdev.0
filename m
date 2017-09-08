From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 0/6] Modify KSZ9477 DSA driver in preparation to add
 other KSZ switch drivers.
Date: Fri, 8 Sep 2017 10:54:05 +0200
Message-ID: <20170908085405.GB16834@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218B7@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219F8@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="bCsyhTFzCvuiizWE"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:33373 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754751AbdIHIyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 04:54:06 -0400
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411219F8@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> From: Tristram Ha <Tristram.Ha@microchip.com>
>=20
> This series of patches is to modify the original KSZ9477 DSA driver so th=
at other KSZ switch drivers can be added and use the common code.
>=20

Please wrap the lines from time to time...


> This patch set is against net-next.
>=20
>  drivers/net/dsa/microchip/Makefile     |    2 +-
>  drivers/net/dsa/microchip/ksz9477.c    | 1317 ++++++++++++++++++++++++++=
++++++

We already have ksz_9477_reg.h. So should this be ksz_9477.c for consistenc=
y?

>  drivers/net/dsa/microchip/ksz_common.c | 1156 +-------------------------=
--bCsyhTFzCvuiizWE--
