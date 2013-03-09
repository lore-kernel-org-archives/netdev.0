From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] bnx2x: update fw to 7.8.17
Date: Sat, 09 Mar 2013 16:18:20 +0000
Message-ID: <1362845900.3768.496.camel@deadeye.wl.decadent.org.uk>
References: <1361993047-10127-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-R7aoBOOFzBVPMNP1xBDN"
Cc: netdev@vger.kernel.org, Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	David Woodhouse <dwmw2@infradead.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50939 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757454Ab3CIQSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 11:18:34 -0500
In-Reply-To: <1361993047-10127-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-R7aoBOOFzBVPMNP1xBDN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-02-27 at 21:24 +0200, Dmitry Kravkov wrote:
> This new firmware includes the following changes:
>=20
> 1. Several corner case bugs in iSCSI code.
> 2. Fixes for FCoE including support for 3PAR targets.
> 3. Fixes for SR-IOV behaviour including:
> 	a. Remove FW assert erroneously triggered during FLR.
> 	b. Several fixes in FLR flow.
> 	c. Prevent VF crash when packet bigger than MTU arrives.
> 	d. Improve security against malicious VF.
> 4. Added CSUM and TSO support for encapsulation protocols.
> 5. Added RSS capability for GRE traffic based on inner headers.
> 6. Added FCoE support for 4-port 57840 devices.
>=20
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
> Please consider adding to linux-firmware tree.
[...]

Applied, thanks.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.

--=-R7aoBOOFzBVPMNP1xBDN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUTtgzOe/yOyVhhEJAQoVOhAAwCFcLAYUial/SwG5demynUOLOImPsxAG
pEeTjLiGkYXdnFOLI+b8TJ6xd7IH7oARNuJ1tleiAJ9gezpMRqVsv0SS7rd14f+M
AND6u7M/Mw2zJMW8EpGr4YNaIZMgHwmowCFI5O03l3/Jq+pGiorwFsyyCRQ9LHqA
q7WsEwmsyWSUENH0XC3Z/7+qOVqccNKODAxZ1llRC7X8Gt1V4bmWAwrIS1XfeM1j
gMvOGjIu8uSrTBMDZ+Q3oW5NEBxsgZ8cYk88J6hUOP171M1XLl4kxVkz+to6cqDR
tqnYpbO6R8ymrr4gJN/uD9b0ZycjU/w5gNSPO0auOqKMhmkId2Tx5cneXKvn6c9d
K1lAYM+nHnJDcGYiwQsnXDwdsKJIlQSJ5A5cPcnn2RW4eT72yKNdxiyoT4bpnlWf
JUJjpEu+iFvz3mQhiEj4hhdxhsoFVUqKaH9vzbsGPRSnaFgTWt96dRZmz+uQhqoU
Vg0zbpvTiCGAikDrcTtPNfULHQHA8VxEMzOhmMFrXGhJy1VvCNxXB98vjaUMBjx4
AeJsZjaB8heuEGJ2lgt+gtf4UdBAi2zn+nt7k8+MzZZszljmRvpM4cZdGFrkBqbn
ipnxk0UVdf2Ftw12q60brGfwzy3cnpFaeDFzsXzkQc08oNZlnZa+V8KpCZUcBEwG
nUEbfSHBq9A=
=WQ7/
-----END PGP SIGNATURE-----

--=-R7aoBOOFzBVPMNP1xBDN--
