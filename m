From: Richard Siegfried <richard_siegfried@systemli.org>
Subject: Re: [PATCH net-next 0/3] A own subdirectory for shared TCP code
Date: Thu, 5 Oct 2017 15:17:31 +0200
Message-ID: <723f73e6-2b26-9828-2ed6-39cba4fbea62@systemli.org>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
 <20171003.160338.1370433279322133749.davem@davemloft.net>
 <d7237d11-ec83-0ef6-d201-da8b99c94b88@systemli.org>
 <20171004202749.GB13247@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="EnMHEuUbDgwOvoFlq230IHg21bRB8Kqq0"
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.systemli.org ([198.167.223.214]:48940 "EHLO
        mail.systemli.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdJENRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 09:17:44 -0400
In-Reply-To: <20171004202749.GB13247@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EnMHEuUbDgwOvoFlq230IHg21bRB8Kqq0
Content-Type: multipart/mixed; boundary="R0TWOwvR3j9D1xFdWeu7L1efa8gaeXAsR";
 protected-headers="v1"
From: Richard Siegfried <richard_siegfried@systemli.org>
To: Andrew Lunn <andrew@lunn.ch>
Cc: netdev@vger.kernel.org
Message-ID: <723f73e6-2b26-9828-2ed6-39cba4fbea62@systemli.org>
Subject: Re: [PATCH net-next 0/3] A own subdirectory for shared TCP code
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
 <20171003.160338.1370433279322133749.davem@davemloft.net>
 <d7237d11-ec83-0ef6-d201-da8b99c94b88@systemli.org>
 <20171004202749.GB13247@lunn.ch>
In-Reply-To: <20171004202749.GB13247@lunn.ch>

--R0TWOwvR3j9D1xFdWeu7L1efa8gaeXAsR
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 04/10/17 22:27, Andrew Lunn wrote:
> Hi Richard
>=20
> It is generally unwanted.
>=20
> Have you tried back porting patches when the directory structure has
> changed? Files have moved around? It makes it a lot harder to
> do. Meaning patches are going to be back ported less often. Fixes
> which could be security relevant might not get back ported, etc.
>=20
> Kernel 4.4 is going to be supported until 2022. So moving files around
> is going to make Greg Kroah-Hartman life more difficult for the next 5
> years.
Ok, I see


--R0TWOwvR3j9D1xFdWeu7L1efa8gaeXAsR--

--EnMHEuUbDgwOvoFlq230IHg21bRB8Kqq0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQFTBAEBCgA9FiEEBgAhuYrOnl9UC7I39kE5zAWb4eEFAlnWMOsfHHJpY2hhcmRf
c2llZ2ZyaWVkQHN5c3RlbWxpLm9yZwAKCRD2QTnMBZvh4cj5B/9ZdrCTZBgUvnLP
0XHRK8XAy8X6zm+Uh+79aARuvq75bKyZ+RSCN6tFLUkZbj42jbOZCyGkkBfrFAwQ
CReb2IdE/q2f3zIUGzUeJSA+CpCz9aVJAtITFSPpWLCL52MOmBA063AzQdrni3e4
YxuhQ01uR0fGvSsOY4ndOnQ2Z4gVC+1DsrzlfMaoXAeK4LR/bsCb25ttAJyWx9T8
th1P/6udWGzndUVpJAObLHJX+3X5jtQ7parIbkYgjwcTJq8nRi4sAx3pdhbcR9Ji
pw82bSNLpqdHB585Wt9B7x/pH0BF9yy3Ntnx5scOvarev1GnkXPJldfe2qW7dIm+
esqQ2l9D
=IOnt
-----END PGP SIGNATURE-----

--EnMHEuUbDgwOvoFlq230IHg21bRB8Kqq0--
