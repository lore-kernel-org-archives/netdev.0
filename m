From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/8] Fix and complete CAN namespace support
Date: Tue, 25 Apr 2017 08:48:28 +0200
Message-ID: <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="PvTaIU752o8Cm6RHWrkpgnIUrFtOWfR3h"
Cc: dev@kicherer.org, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PvTaIU752o8Cm6RHWrkpgnIUrFtOWfR3h
Content-Type: multipart/mixed; boundary="B7qBsTKB1X1b4wtIfqwQU4N9AJIvQL4vC";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org,
 davem@davemloft.net
Cc: dev@kicherer.org, netdev@vger.kernel.org
Message-ID: <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
Subject: Re: [PATCH 0/8] Fix and complete CAN namespace support
References: <20170425061945.28722-1-socketcan@hartkopp.net>
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>

--B7qBsTKB1X1b4wtIfqwQU4N9AJIvQL4vC
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/25/2017 08:19 AM, Oliver Hartkopp wrote:
> Hello Dave,
>=20
> unfortunately the initial network namespace support by Mario Kicherer
> (8e8cda6d737d) slipped into net-next without further review and Marc pu=
shed
> the code without my Acked-by. Due to the fact that this code was in net=
-next
> now I spent some nights to fix, clean up, finalize and test the missing=
 pieces
> for the namespace support for the CAN subsystem in net/can.
>=20
> As Marc is currently *VERY* unresponsive on the mailing list due to his=
 'real'

=2E.. and holidays :) But I'm back in the office now.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--B7qBsTKB1X1b4wtIfqwQU4N9AJIvQL4vC--

--PvTaIU752o8Cm6RHWrkpgnIUrFtOWfR3h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlj+8T8ACgkQHv7KIOw4
HPZAVwgAt76bibjDKKqlpgxhv2NHztr7bgPbSH2oqTJ+lXbAcukXh1/RFeZMCvb5
9gTgJOLoq+Erl3xYDvwkPk5MwzB74m313ivdYr35+NGb/cMVzUJP755EzVx8SvQC
Kfg3bVRjYsL4I1SIu1ZdytOhIb7pTpcTXGBj7ha3rbuJNdXS9buey+kHSddGxpHu
SyDKRJdkQUZdOLQcDp3terT4zkM9uX+R5VfgEYh82GSCa9/OTO8jcjFfEBZJ0aGQ
rix4NmG6jdmOxGAEzL2DswJIeWhRz8XTyS9rfLQGcjjORk+4r4QKrVAuZycmCPam
rP/ZxkaNSrxpbXcaMFPATeGl2HZxNA==
=DZCC
-----END PGP SIGNATURE-----

--PvTaIU752o8Cm6RHWrkpgnIUrFtOWfR3h--
