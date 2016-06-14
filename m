From: "Eggert, Lars" <lars@netapp.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 14:54:00 +0000
Message-ID: <512CF3B7-F805-49E5-9CBE-6D51F8C5E70F@netapp.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
 <575FEA4B.2000603@virtuozzo.com>
 <3758708E-B5DE-4D8B-A8CC-37346F994B32@netapp.com>
 <1465909415.7945.182.camel@edumazet-glaptop3.roam.corp.google.com>
 <1465909802.7945.183.camel@edumazet-glaptop3.roam.corp.google.com>
 <183844BD-7118-44EB-9D97-62B2A164D7BC@netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_0A3C98E2-D252-4893-A997-648E3F6DDB5F";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Pavel Emelyanov <xemul@virtuozzo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	Andrey Vagin <avagin@virtuozzo.com>,
	"Honda, Michio" <michio@netapp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:54977 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789AbcFNOyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 10:54:07 -0400
In-Reply-To: <183844BD-7118-44EB-9D97-62B2A164D7BC@netapp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_0A3C98E2-D252-4893-A997-648E3F6DDB5F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On 2016-06-14, at 15:24, Eggert, Lars <lars@netapp.com> wrote:
> On 2016-06-14, at 15:10, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Also, is it a regression ? Was this working better with an older =
linux
>> version ?
>=20
> No idea, 4.6.0 is the only kernel I ran this on (is a new project). =
What would be a good older version to check?

FWIW, I had 4.2.0 available on this machine, and it has the same =
problem.

Lars

--Apple-Mail=_0A3C98E2-D252-4893-A997-648E3F6DDB5F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXYBqIAAoJEFS1wwm/cMFX9s0P/iCSvdbWfNJKXwVxfvSAJvkC
U+9HrXmm6egoBwLnkCN5LPg0EVs0yr6HO4ItkOLqDc+Lz/NimMEoSMr0UJz5tNRG
rgUyHiqpYcqdptdmxcwHL6+ynf75nwGzT9/4wzyAS5aO0ss1IzuZ3jdmkHUHnY1W
ahANuQoetSONsGMpdS9dLrndGC6E0qGvtWNh5tjLH0LTgVP8qSPH94/4atWMdJ2e
cMTApT6LRpqNpRN1AMnHcJ3U6JnCUpPbcy3k5hqS5kNdN6UCDtuflHYBkKAJqE+L
uripMaa+Z7fTzm7KQq287AakZjXqOufUtxWDI8qLkwVgxIoMr+IHR6PHMRNBtj5Z
9eVCYty/3T7yNNtSNwpn40qA5MDC1PlARxyKGQz9A+2Rcf6CR3JZWRlcAB+ForAP
E2FH1nZMBOxK/u/PN++vFBPRwvVLJmSOF53DOIzR69Uj9vHTSKBHMRcenNZQgpsT
XQJsqDAt74UD2J1EoqMDXNQb6yprOA59CyK5naQp5D2ELpuAG7tF1i6G4M9sV/uQ
i1Xvo15OPIXefOJpfoKh3ryHIXmEd86DxSMv2r6LSExIk4FaxRm9XFsfUwyXhxtt
trHu+ENNIGq2qVmeGQuxy4yiA/yyg0OP6dWYpAPCsP5bZ68jTLEnoc16IuJoIiJV
97oujanoVct5yUN2g18B
=k15S
-----END PGP SIGNATURE-----

--Apple-Mail=_0A3C98E2-D252-4893-A997-648E3F6DDB5F--
