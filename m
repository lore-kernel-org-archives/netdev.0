From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2 v2] igb: Add macro for size of RETA indirection table
Date: Wed, 31 Jul 2013 05:12:21 -0700
Message-ID: <1375272741.2877.34.camel@jtkirshe-mobl>
References: <1375271273-20122-1-git-send-email-laura.vasilescu@rosedu.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iM6uJNgb2NSbNZuhdQ4m"
Cc: netdev@vger.kernel.org, carolyn.wyborny@intel.com,
	anjali.singhai@intel.com, alexander.h.duyck@intel.com
To: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59112 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360Ab3GaMM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 08:12:26 -0400
In-Reply-To: <1375271273-20122-1-git-send-email-laura.vasilescu@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iM6uJNgb2NSbNZuhdQ4m
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-07-31 at 14:47 +0300, Laura Mihaela Vasilescu wrote:
>=20
> RETA indirection table is used to assign the received data to a CPU
> in order to maintain an efficient distribution of network receive
> processing accross multiple CPUs.
>=20
> This patch removes the hard-coded value for the size of the
> indirection
> table and defines a new macro.
>=20
> Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
> ---
> Changes since v1:
>         * enhance commit description
>=20
>  drivers/net/ethernet/intel/igb/igb.h      |    2 ++
>  drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)=20

Added to my queue, thank you Laura!

--=-iM6uJNgb2NSbNZuhdQ4m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR+P8lAAoJEOVv75VaS+3O95oP/RPIE7r3wbZlmo8oNyWvIMFi
3Ov31wH1voE+rSX8zqg65iqlUnyMy+hLTAusbOc0oOzQfvAkiFgICdQlcq+Q4lpu
/cQys4/ZRU+9OaKW7W1cYIk09l1P8qfW6qObHZLEwDxdSspj8wop7CacF/85okVZ
pePgJ2NxBrDSZs6Kim3vbuZJcbQ21XyNyLJM7959LEjm7lrN9V5SmF6bI5X2ACH2
qnHxwcWYamPD0WU6QMdGY0O6QXWjQKXO0BO/pltS6NHGPAPsuUryN1wxOfkHLMk7
3pZBTXTyqR8aNd9ikNZWVasoQQcwiC2Zm0xj7vhvPZ2S0dmQwJ1Zo38M/BePPanw
nBqhjEOFH1AQP36LoITkkprkkPgtnBTL/0xjR+iPq9SI9GNAkO6j4L4suulhr8FM
ixEFnWJYAIxGkFRPMHtBjbqr/D+TaXxKPYSKI1iwIky7ADTrx5zwYIzidTCbLXv9
FyXsEMBpN+Uq7fLvjQAuLlsLE0yh32P1mb1HdkmuzmYUlreE9pQXut/crA9A52q4
Qqv3x84dq0/DqVhv0MpbPIseeAETO3wHFix9j0qBgS7+23k355zMwoWqR2q+VJyd
OrqmmeY1DNPo7XY9r45QHiwMvOPaaIBEtFnLYXQhjKKfWmTJX3KTgUQ/Keb11vW/
HLSGsdYu0XTgJCry3UgC
=GKLO
-----END PGP SIGNATURE-----

--=-iM6uJNgb2NSbNZuhdQ4m--
