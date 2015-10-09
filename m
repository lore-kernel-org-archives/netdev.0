From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 4/9] net/can: can_dropped_invalid_skb can be boolean
Date: Fri, 9 Oct 2015 12:14:31 +0200
Message-ID: <56179387.1090301@pengutronix.de>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
 <1444310942-4428-5-git-send-email-bywxiaobai@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="VpTCxlCrmt8oR6vVQ06jGJXveD3PLWcI2"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yaowei Bai <bywxiaobai@163.com>, davem@davemloft.net,
	tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:32962 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757403AbbJIKP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 06:15:59 -0400
In-Reply-To: <1444310942-4428-5-git-send-email-bywxiaobai@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VpTCxlCrmt8oR6vVQ06jGJXveD3PLWcI2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/08/2015 03:28 PM, Yaowei Bai wrote:
> This patch makes can_dropped_invalid_skb return bool due to this
> particular function only using either one or zero as its return
> value.
>=20
> No functional change.
>=20
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Yaowei, feel free to send the CAN patch as part of your series directly
to David.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--VpTCxlCrmt8oR6vVQ06jGJXveD3PLWcI2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWF5OHAAoJEP5prqPJtc/HqwoH/A0qzoDjHKmrC27UE1ehpIj8
FriJtOtJxlTjBHuDixkszlL/2Hzt2a0L/7Yxv6fS8P05eZlLbw22LSn6Ic6RHjTZ
RlO4v6wrINsQl7xdCnI61lxoCTonMr3JOI1MqBTJxXjsl/FiAk2j9GRt44edDy8I
DfZNZpV5G5X4eIM5SiYRBvDZGS3sFpN/Os5u44yPjss48598lN+y2f5LAMLTeh2o
CWcylJqiw6L/lmKK8OfIswU2Ti65It9d9xkZzMgbvtLw/337HBcHqKGBJB41jQkC
FRc54WaLk4XXzWHvus2uXL5MLzvCYGsx0NVHEYU1IXToTPB2+168gZvhjwr2jzQ=
=uE4y
-----END PGP SIGNATURE-----

--VpTCxlCrmt8oR6vVQ06jGJXveD3PLWcI2--
