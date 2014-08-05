From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH] batman-adv: Fix out-of-order fragmentation support
Date: Tue, 05 Aug 2014 09:17:36 +0200
Message-ID: <53E08510.4020308@meshcoding.com>
References: <1407167221-10575-1-git-send-email-antonio@meshcoding.com> <1407167221-10575-2-git-send-email-antonio@meshcoding.com> <5564567.83o54DtWyR@bentobox>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="feT0whvmIQ4r3tu77LNeTlnidiCnRT133"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>
To: Sven Eckelmann <sven@narfation.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:24220 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756422AbaHEHSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:18:21 -0400
In-Reply-To: <5564567.83o54DtWyR@bentobox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--feT0whvmIQ4r3tu77LNeTlnidiCnRT133
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/08/14 18:26, Sven Eckelmann wrote:
> On Monday 04 August 2014 17:47:01 Antonio Quartulli wrote:
>> This problem was introduced in 9b3eab61754d74a93c9840c296013fe3b4a1b60=
6
>> ("batman-adv: Receive fragmented packets and merge").
>=20
> This is not a commit id from the kernel tree but the one from your out-=
of-tree=20
> repository at http://git.open-mesh.org/batman-adv.git .=20
> 610bfc6bc99bc83680d190ebc69359a05fc7f605 seems to be the one of Martin'=
s=20
> commit when it was applied in the kernel repository.

Thanks Sven!


David, I "fixed" the commit message and pushed the tag
"batman-adv-fix-for-davem" again. If you pull now you will get the
correct text.

new head is:
batman-adv-for-davem =3D d9124268d84a836f14a6ead54ff9d8eee4c43be5)


Cheers,


--=20
Antonio Quartulli


--feT0whvmIQ4r3tu77LNeTlnidiCnRT133
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJT4IUUAAoJEJgn97Bh2u9eEFcP/1w+do6LLcbY+XOBIyZ5mTiy
QeZT+wrjQNWBAm+fP5tKeFZawgoHK5BRm15RGpXOd5AMuwH9JIabWrF4ajEyWNCQ
3MQDhZFvFAn1Bcn5DXkoCdKWjeW9LHRW4UdNWQcT9KnJf8Pw1LnvYqHvouOyd9NZ
915+pWdYv4ulfgwbexapxynHz8npFpjxwuUxflHQMN7sG+bZWRtkdy7AI79pcWBn
DcQzmqVAtLTHJCfUdSBNsqBtiNUBc98lTptgOOC5U3DybQpNL7Lo8xQGpj8StS/C
i45j3KaZDupqGfvwtsPKl7DIs3QH7WvxE0J4Ja827vqFkV4Etlj/0sVL6iJH2H2n
ARt3P1h0QB3WhjzRumBHmgVEfnDT7LN9fLxqsFN0RlFUQR41P6TlOUuZeHeyUfAk
vMQxJumWvvKOMctInS1tY0vB0aC3eppZN2GsXPVmB6ruxI6GBVF33YqXn5MHMVX2
7CqX1HxshnKFg7q5v2jMG1CBYERn7HISYfiDVT1nbFYDIiT6JLZ23BuggkFr8Fnp
PW2ExR5guq/gzrEJizEub3ybpSwDzj8nw6OCdDcyxgYVgmZ2Bt24xIsxUR1xKJOA
T7FvOsqbRfx4CdJE9yVXq9L7Yn2fYwuxdcDChYBNeUdlkikD031F0ap2l+5VdFYn
FIHplRDI/RdlOAJTxrvr
=BrDr
-----END PGP SIGNATURE-----

--feT0whvmIQ4r3tu77LNeTlnidiCnRT133--
