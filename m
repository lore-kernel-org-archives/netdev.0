From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/8] Fix and complete CAN namespace support
Date: Tue, 25 Apr 2017 10:45:05 +0200
Message-ID: <9a88aee4-ba8c-00e7-2525-e300d905e593@pengutronix.de>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
 <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="POkesWWaVvhHIv5WDXgO2k4bWUIMMTUIg"
Cc: dev@kicherer.org, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--POkesWWaVvhHIv5WDXgO2k4bWUIMMTUIg
Content-Type: multipart/mixed; boundary="ved3uI0blvX6UEqRNPj0w7axS55OlSEfo";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org,
 davem@davemloft.net
Cc: dev@kicherer.org, netdev@vger.kernel.org
Message-ID: <9a88aee4-ba8c-00e7-2525-e300d905e593@pengutronix.de>
Subject: Re: [PATCH 0/8] Fix and complete CAN namespace support
References: <20170425061945.28722-1-socketcan@hartkopp.net>
 <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
In-Reply-To: <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>

--ved3uI0blvX6UEqRNPj0w7axS55OlSEfo
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/25/2017 08:48 AM, Marc Kleine-Budde wrote:
> On 04/25/2017 08:19 AM, Oliver Hartkopp wrote:
>> Hello Dave,
>>
>> unfortunately the initial network namespace support by Mario Kicherer
>> (8e8cda6d737d) slipped into net-next without further review and Marc p=
ushed
>> the code without my Acked-by. Due to the fact that this code was in ne=
t-next
>> now I spent some nights to fix, clean up, finalize and test the missin=
g pieces
>> for the namespace support for the CAN subsystem in net/can.
>>
>> As Marc is currently *VERY* unresponsive on the mailing list due to hi=
s 'real'
>=20
> ... and holidays :) But I'm back in the office now.

FYI:
This series is included in the latest pull request:

git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git
tags/linux-can-next-for-4.12-20170425

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ved3uI0blvX6UEqRNPj0w7axS55OlSEfo--

--POkesWWaVvhHIv5WDXgO2k4bWUIMMTUIg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlj/DJIACgkQHv7KIOw4
HParpggAvNjXK2xWIcr/oEY/BA5lbaXIXLufTKpHmq5a7z20q9yiovj8juatmu3x
5ogXPGR1v8q+yWRcIzAguivCgmKzlI7ZO3+AMBT+pKWHoToQZxgHFWjYQwp9csvV
OQmLB5g8KaAZDTxuQIoF4ekc5DajMtAy0jU6RcF7ds7Ehnsp2LEVRZH3QWAoL+p9
VGl5kKAYqEGOVXUGAd2OrfKnGGWJw8tIb6KMPYQL6a+KhaTu4AIvXVUwze1CnWm0
leODLIWwdciMwJGivOFZjNSDRVI6qwQQ7qPrAupgsE7m6ZVJgH8VrpX3ucaVCYCS
WsPBX4qMbXzEVt0Y9BtonNpz2Rqd7Q==
=9MSb
-----END PGP SIGNATURE-----

--POkesWWaVvhHIv5WDXgO2k4bWUIMMTUIg--
