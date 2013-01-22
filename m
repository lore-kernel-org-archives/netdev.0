From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: 69b08f62 breaks ethernet on atl1c based Eee PC 1011px
Date: Tue, 22 Jan 2013 13:31:23 +0100
Message-ID: <20130122133123.57085db8@milhouse>
References: <20130121222926.392f1244@milhouse>
	<CANn89iK6kuLeg1TCobdHMKK5dYZuP0mRSb25v9C4pdP2F7MrLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/IiT2p0ctq3IX2qa0mW6VGra"; protocol="application/pgp-signature"
Cc: linux-netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:55719 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861Ab3AVMbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 07:31:49 -0500
In-Reply-To: <CANn89iK6kuLeg1TCobdHMKK5dYZuP0mRSb25v9C4pdP2F7MrLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/IiT2p0ctq3IX2qa0mW6VGra
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 21 Jan 2013 15:25:02 -0800
Eric Dumazet <edumazet@google.com> wrote:

> I guess you should reproduce the bug using current Linus tree.


The problem seems to be fixed in latest Linus tree.

Any idea which commit fixed it, so we can backport it to 3.7.y?

--=20
Greetings, Michael.

PGP: 908D8B0E

--Sig_/IiT2p0ctq3IX2qa0mW6VGra
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ/oabAAoJEPUyvh2QjYsO334QAMHQ8b295l9zRYaEiyogvzq4
k/s66OjekFWTXZgukD/jsKSD6cXGCTH69JdNIacEpty0pydBuCNTxCwzH3a6POgi
UboX5mrkzpsRzXO6p4hquhwc/6wKVm3ln+zSBR10NwmoVFkCZQo9EqE52fNN89xC
mrH8mKJXUnrOBf4AFh1WGMzALqPSEx/cfFUNEXf4EXAwo4wTQbWKIlQ5l7EkJE/q
wqJsy/0+yq6oQCmX8jXDo3nnd7E03bNN9B2EQxZq/iRJr0KLHx2isBY6Du1FjL37
eVP6Aikyl7wiIV/xdEc0pRrRfvRUrnkhdjVYtmXtAN3XMTkG2KnZFgWxd6Gpnenf
fS3B5bz3cb0QH3EPh8J1qUulDSiZa763ja7yvEnqvGS/5389xqMLbZmX+L91njKN
XJDQC9Y6+XMyKUjLEDaUopEeyQPqAfdWAyDcntpQ05te+keWtan62KoZUFe0TMiF
86GXJOEWLKv62PGotoulAsV3lIA3Wn2ceFPBnmMyOchPzs0jmp7Hbr2ZU8mvRfkU
frl5yc2MPPZOmKCMtLu92xCrpzOEKjwY+3wE4xZ52Rd8UYXBhbM4KctTzBxHYc7C
h9UbHJL8Eb/phSV6Oovw+JJcVv+1QcKjOD8K+A2lXOXO6Awmow+GYl/Wbc7BJLHq
j7ewmX6goFWVbqqauYT+
=AkdG
-----END PGP SIGNATURE-----

--Sig_/IiT2p0ctq3IX2qa0mW6VGra--
