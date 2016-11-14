From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 2/3] net: ethernet: sun4i-emac: Allow to enable netif
 messages
Date: Mon, 14 Nov 2016 20:00:04 +0100
Message-ID: <20161114190004.qrmtnqmrbrn6sa24@lukather>
References: <20161114175807.4747-1-michael.weiser@gmx.de>
 <20161114175807.4747-3-michael.weiser@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="rdrwnhytgsjc4egr"
Cc: netdev@vger.kernel.org
To: Michael Weiser <michael.weiser@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:52766 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754938AbcKNTAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 14:00:15 -0500
Content-Disposition: inline
In-Reply-To: <20161114175807.4747-3-michael.weiser@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rdrwnhytgsjc4egr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 14, 2016 at 06:58:06PM +0100, Michael Weiser wrote:
> sun4i-emac has the ability to print a number of diagnostic messages using
> dev_dbg depending on message level settings implemented using netif_msg_*
> macros. But there's no way to actually enable them.
>=20
> Add the ability to switch diagnostic messages on using either a module
> parameter debug or ethtool -s <netif> msglvl <flags>.
>=20
> Signed-off-by: Michael Weiser <michael.weiser@gmx.de>
> Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
> Cc: netdev@vger.kernel.org

Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--rdrwnhytgsjc4egr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYKgm0AAoJEBx+YmzsjxAgp6cP/jE+r121YG2JHa2CqQ9ZVtsG
dtsiaUaxjUkXAwV/HHNJ5omWPdA89wTZodbEG0MsRgjkCxSRoL9yxlUy7eDWUtHC
sfYxZRPw20CKJUXD61wEdGpRso9I7Juq9u9ClGUBSaWC6+o+6Ku5SeZmY2IGuHzO
dCxl5JhgnoQLARHBAsmAh3nI5J0DOM+JJ2Hvnj8A/WuUoALJ792opFNREgK5C6mV
3AD+LuDsiDZcvcm8I7yaAcooMJ4iOX1NOK/bOKP5F9yDHkr9+0SWrs6aqJz5cyjl
ePYLxwGZbvwbFOiFKOaqdlsqj4+WYrm1UU70tX3jkXLA+afc8ogE9pgh0Jm+UdLG
UuBR+Fs+B8hcX7mCmxtt6iFc3KYDbLtO9r1nf5UqWOKsDPF2Iai/65z8DpOhviP2
yYYPIVpgqDn001i/0ieKeHhI/CDnc02pj4ts1ll68jtnXGkvXn4RhNIeZkP7Pygt
R+q2Iz5qu4dCFUBkTaVB5dP/+Hw6nOcBzVBeFTx+P+Go0DH56l+T+6MVKvv6KWWr
x8YKLMPXRR1NgeMFDSKt2x1Wh0E04oETj2OsG1P/43vh78uxnaIZVlNyxm9/dDNy
IKdOFSElT4DxqbB7cXG8fgmkvy7ScQVJ5R+oN8/EI8ede1VR58tm2OqSq4cxI1Fi
heyBZj/8NUzGfuGIxPbM
=ax+P
-----END PGP SIGNATURE-----

--rdrwnhytgsjc4egr--
