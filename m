From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 0/8] Fix and complete CAN namespace support
Date: Tue, 25 Apr 2017 10:49:31 +0200
Message-ID: <f1694918-bce8-f533-1c55-fef36dfb7aed@pengutronix.de>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
 <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
 <9a88aee4-ba8c-00e7-2525-e300d905e593@pengutronix.de>
 <d852c2e7-f543-ecea-01f0-9f66d8741476@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="0gHOD4NVc7R7G6fkanRC6rfsIlX1jPBml"
Cc: dev@kicherer.org, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:53903 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1176921AbdDYItk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:49:40 -0400
In-Reply-To: <d852c2e7-f543-ecea-01f0-9f66d8741476@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0gHOD4NVc7R7G6fkanRC6rfsIlX1jPBml
Content-Type: multipart/mixed; boundary="mFoqQ6NiMNW2OUvcrPvVhDCBF0sCnsrbr";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org,
 davem@davemloft.net
Cc: dev@kicherer.org, netdev@vger.kernel.org
Message-ID: <f1694918-bce8-f533-1c55-fef36dfb7aed@pengutronix.de>
Subject: Re: [PATCH 0/8] Fix and complete CAN namespace support
References: <20170425061945.28722-1-socketcan@hartkopp.net>
 <8fc17f07-f165-970b-f96a-1d920302fd00@pengutronix.de>
 <9a88aee4-ba8c-00e7-2525-e300d905e593@pengutronix.de>
 <d852c2e7-f543-ecea-01f0-9f66d8741476@hartkopp.net>
In-Reply-To: <d852c2e7-f543-ecea-01f0-9f66d8741476@hartkopp.net>

--mFoqQ6NiMNW2OUvcrPvVhDCBF0sCnsrbr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/25/2017 10:48 AM, Oliver Hartkopp wrote:
> On 04/25/2017 10:45 AM, Marc Kleine-Budde wrote:
>=20
>> FYI:
>> This series is included in the latest pull request:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next.git
>> tags/linux-can-next-for-4.12-20170425
>>
>=20
> Ok, thanks!
>=20
> Sorry for pushing a bit harder this time. But I wanted to make sure tha=
t=20
> we don't get incomplete stuff into the merge window.

np :D

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--mFoqQ6NiMNW2OUvcrPvVhDCBF0sCnsrbr--

--0gHOD4NVc7R7G6fkanRC6rfsIlX1jPBml
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlj/DZsACgkQHv7KIOw4
HPb03wgA2JJGNnSdvBeUnNXq+4v53+xcqazwrHxl0Ze164wLxt/swAP7FHSQR2dc
wsHPfrIUHmoC4e+FaTbIXwUT+NNDLfF07U3O+EBDxhPbFwvCDtJlD8U6gxWi41H/
QAXK5zSkNa3KY1esqeAvHWCSPEOFB/vF8Av3ubsCLLMryXYp0UDUdGtXPlapXMxr
Vq5R7G35+/EOrlWg2jbOW5Vh1VYVVi60ohdJqRQ2xOPavTTiG6yW+nOiunAw3r59
Gk5hI6gA8cCV0k2ro0av/aRAWOhTxwxUlqblU6wZ+9nX+nB24THLr/IUk2LJfQ3b
a7ZVSABuVzy64YE3xjlzPOzu8d9U+g==
=d/iJ
-----END PGP SIGNATURE-----

--0gHOD4NVc7R7G6fkanRC6rfsIlX1jPBml--
