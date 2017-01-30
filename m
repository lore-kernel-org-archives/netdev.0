From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can 2017-01-27
Date: Mon, 30 Jan 2017 10:12:48 +0100
Message-ID: <3c82da6b-86fa-ae93-9ffe-456f013c5e8e@pengutronix.de>
References: <20170127204627.11735-1-mkl@pengutronix.de>
 <20170129.184606.7321731386358543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="xSSSn6d8FG7vBrSdURqmu8lxiBQH73Blq"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50053 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751052AbdA3Ju2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 04:50:28 -0500
In-Reply-To: <20170129.184606.7321731386358543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xSSSn6d8FG7vBrSdURqmu8lxiBQH73Blq
Content-Type: multipart/mixed; boundary="iF9QwdPLJnXQpbwoxsVrP0sQUBOddjEfm";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org, kernel@pengutronix.de
Message-ID: <3c82da6b-86fa-ae93-9ffe-456f013c5e8e@pengutronix.de>
Subject: Re: pull-request: can 2017-01-27
References: <20170127204627.11735-1-mkl@pengutronix.de>
 <20170129.184606.7321731386358543.davem@davemloft.net>
In-Reply-To: <20170129.184606.7321731386358543.davem@davemloft.net>

--iF9QwdPLJnXQpbwoxsVrP0sQUBOddjEfm
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/30/2017 12:46 AM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Fri, 27 Jan 2017 21:46:26 +0100
>=20
>> this is a pull request for net/master.
>>
>> It consists of a single patch by Eric Dumazet, it fixes a kernel panic=
 at
>> security_sock_rcv_skb.
>=20
> Oops, I applied Eric's patch directly since you ACK'd it.

It was Oliver who Ack'ed it, but no problem.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--iF9QwdPLJnXQpbwoxsVrP0sQUBOddjEfm--

--xSSSn6d8FG7vBrSdURqmu8lxiBQH73Blq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAliPA5IACgkQPTuqJayp
JWpRXAf+PRrY19EpKVeQc9hIQ6nNHmeIxUf7cYCCiOzvNrO00oO9oRIAznxzwkHI
TCpQ03yWoJwZZg1JachfzFn5bwKQlOYfiNFsHbE9KKMSJLX0QKxWYDYwR9sPFuUr
jiR3AdwlR9W51Ap15aOkwB/GrNvJ96bqRnkgmHwhKdQgkT/k3kWP6qd3Ps4SAQo4
NQ6JqGbExbOeYdTHqVJAUL1N6YYtqZXTi4QcyPYdS7RzBI4IP60Sy/XNnSoNjPKY
gyVHTQSfQgb/L1raLGTs53ueo2KQv0VQDhntd0vdoj32SCmamlrGob/h6CQ6Mo2T
rR88qrl1b8lmVPVR5vk8c3/Z3X/5dw==
=oBs2
-----END PGP SIGNATURE-----

--xSSSn6d8FG7vBrSdURqmu8lxiBQH73Blq--
