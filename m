From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: atl1c issues on 3.8.2
Date: Thu, 14 Mar 2013 23:17:46 +0100
Message-ID: <20130314231746.44a93e4d@milhouse>
References: <20130312161753.281681f2@milhouse>
	<1363103144.13690.12.camel@edumazet-glaptop>
	<20130312180942.4198e88e@milhouse>
	<1363154258.13690.40.camel@edumazet-glaptop>
	<1363271460.29475.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/B4OrEvT_bf4jAkq9XuAg21Q"; protocol="application/pgp-signature"
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"David S.Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:34398 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216Ab3CNWTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 18:19:15 -0400
In-Reply-To: <1363271460.29475.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/B4OrEvT_bf4jAkq9XuAg21Q
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 14 Mar 2013 15:31:00 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> And it seems the possible fix is here :
>=20
> http://patchwork.ozlabs.org/patch/227666/

I can still reproduce with this fix applied.

However, I noticed that I cannot reproduce, if the wireless interface (ath9=
k) of
the netbook is down while testing the ethernet. The wireless does not carry=
 any
test traffic. It's just idle.
I do not know if this always had been the case, because wireless was always=
 up (and mostly
idle) in my previous ethernet tests.

--=20
Michael

--Sig_/B4OrEvT_bf4jAkq9XuAg21Q
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRQkyKAAoJEPUyvh2QjYsObMIP+wY6ux1ktN5iSyYpP+JmqJun
gnfuzk2Nwt8NqimEijWSkjKChmkjZUS1DTxmrl9SGpQLYGw9Gmx7J23E2s7w9a2b
IGlL7rjmc0Dbc5GygfIdH9u4TW4s8jo1ajWNj4BhBXwWa1VLThxzFpA2j/kVtDpg
LYrZc3R1+uT7pBL1PYJJM7IOyX0pARMl0HzNOT4tZpa0nYER87eTYHGcrxnh8+dc
46cL391EqRbWKafSZJhltxo58DozKhjwEF412MWzVsGFl8WRvqrLdx/KM5V5bEFv
pFj940UJxuPOIcE7VjvosOgPnRHKhTzZtkq8UusZMZYCCcuTPN2efcsjXyBSU10D
nbpVrg0AL+jVut1Ids4vF8BfIMsc46PK5hz0rNxLli4TUofmTsVc1v+lnzJggOq/
siMGK3rBY7HoTxPi7nJbdxupDJKIz+hoEpwNZaC8XW0iuXszI9o0uHmmRVZmE+Ic
YHO2VUidPCanlr/a/gmmcmcaAAlRzjw2bI8dt+g7pybezEnYps5kwpu1yhVOIu9o
kFQvD4U3suPGj646cinE0swaKQFIIMnH6oL1B+uccpibPJ6Plr1nry0xhT8so79n
BZrsAywkrAtCyCIUdx7FweJtJnBW5+pg/eYrAbwoN5LFVX/ulo1uoIpB0TL4IOHA
nuIrMGFSF/3eIXF7CtAg
=5ZMv
-----END PGP SIGNATURE-----

--Sig_/B4OrEvT_bf4jAkq9XuAg21Q--
