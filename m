From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can 2017-04-04
Date: Fri, 7 Apr 2017 11:00:20 +0200
Message-ID: <bd352fa3-76ba-266d-0831-7cfe5e0abb36@pengutronix.de>
References: <20170404155949.30965-1-mkl@pengutronix.de>
 <20170405.103734.436486519653060340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="0ScKll3hvORtvvXF33NE0Ew26QoFpjK3P"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170405.103734.436486519653060340.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0ScKll3hvORtvvXF33NE0Ew26QoFpjK3P
Content-Type: multipart/mixed; boundary="kCSKTxVXgf2qT8GDCM7Rs5qgMTUBFpuOd";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org, kernel@pengutronix.de
Message-ID: <bd352fa3-76ba-266d-0831-7cfe5e0abb36@pengutronix.de>
Subject: Re: pull-request: can 2017-04-04
References: <20170404155949.30965-1-mkl@pengutronix.de>
 <20170405.103734.436486519653060340.davem@davemloft.net>
In-Reply-To: <20170405.103734.436486519653060340.davem@davemloft.net>

--kCSKTxVXgf2qT8GDCM7Rs5qgMTUBFpuOd
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/05/2017 07:37 PM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Tue,  4 Apr 2017 17:59:47 +0200
>=20
>> this is a pull request of two patches for net/master.
> ...
>> The following changes since commit 0b9aefea860063bb39e36bd7fe6c7087fed=
0ba87:
>>
>>   tcp: minimize false-positives on TCP/GRO check (2017-04-03 18:43:41 =
-0700)
>>
>> are available in the git repository at:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git=20
>=20
> Pulling this doesn't give me anything:
>=20
> [davem@kkuri net]$ git pull --no-ff git://git.kernel.org/pub/scm/linux/=
kernel/git/mkl/linux-can.git
> From git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can
>  * branch            HEAD       -> FETCH_HEAD
> Already up-to-date.

Sorry. The "tag" some git lost, here it is:

---

The following changes since commit 0b9aefea860063bb39e36bd7fe6c7087fed0ba=
87:

  tcp: minimize false-positives on TCP/GRO check (2017-04-03 18:43:41 -07=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/li=
nux-can-fixes-for-4.12-20170404

for you to fetch changes up to ca257b9e2d807ab6cb2678ecc7b74aaf4651f597:

  can: rcar_can: Do not print virtual addresses (2017-04-04 17:49:59 +020=
0)

----------------------------------------------------------------
linux-can-fixes-for-4.12-20170404

----------------------------------------------------------------
Geert Uytterhoeven (1):
      can: rcar_can: Do not print virtual addresses

Markus Marb (1):
      can: ifi: use correct register to read rx status

 drivers/net/can/ifi_canfd/ifi_canfd.c | 2 +-
 drivers/net/can/rcar/rcar_can.c       | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--kCSKTxVXgf2qT8GDCM7Rs5qgMTUBFpuOd--

--0ScKll3hvORtvvXF33NE0Ew26QoFpjK3P
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAljnVScACgkQHv7KIOw4
HPYhJQgArotZ5TK2PuceX0YkNOl95WdBT6ig1/kYeyguyX6gNcTMdPzu/XgwpKWl
9mtl3VCYo1ix9uQAfWkO9husyO5S5vUYlJtrNGSGhh8fxGUOS8UJFCIgPwlIpZbi
C7OZqV8fx6cKIAhEpgy9i+dlFS80Ffwivo0u1WEfUnzm6gUaQHL/K24eKfaISVTV
2UUkvdnu6ISep5j1JYPNvNNC5XBtrC0iFgGbfqvnJVKQwr3gSL48oHG9fbjBdmUp
K54ia1YU9G76XsxWwgpqmO7ZHPLSoY2yVHFeRo+2fixi8uCfcx22HipknVNPZcP6
4dxfGvHe2eF4sLo1k0YkATNORjlgQA==
=9J1q
-----END PGP SIGNATURE-----

--0ScKll3hvORtvvXF33NE0Ew26QoFpjK3P--
