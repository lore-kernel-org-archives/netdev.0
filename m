From: Matt Brown <matt@mattb.net.nz>
Subject: Re: [Madwifi-devel] d80211: ANNOUNCE: DadWifi,	a port of MadWifi
 to d80211
Date: Thu, 19 Oct 2006 14:18:29 +1300
Message-ID: <4536D265.3090307@mattb.net.nz>
References: <20061018001403.GA22990@devicescape.com> <20061018101605.GA1767@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig482EE4716ADE3E02B0F76929"
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from carbon.meta.net.nz ([219.88.251.16]:52931 "EHLO
	carbon.meta.net.nz") by vger.kernel.org with ESMTP id S1945953AbWJSBTE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 21:19:04 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061018101605.GA1767@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig482EE4716ADE3E02B0F76929
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Christoph Hellwig wrote:

> Guys, why do you waste your time on doing stuff that's useless for most=

> of us, and that people can't even legally redistribute.

Well that may be your opinion, but it's certainly not mine. We had just
discussed starting an in-house project to port the HAL to the d80211
stack when David made his announcement.

The reason? While we'd obviously prefer that the HAL didn't exist, if
it's going to exist we would far rather that it had a common 80211 stack
on top of it, so that we can easily switch to other chipsets and retain
the same featureset.

Reducing the number of 80211 stacks in use in Linux is a great thing.

> Please switch to openhal or the openbsd code and we all owe you a lot o=
f
> beer at the next conference :)

I'll be very happy to provide beer for any devicescape employee I meet,
simply based on the initial release of dadwifi.

Cheers

--
Matt Brown
matt@mattb.net.nz
Mob +64 21 611 544 www.mattb.net.nz


--------------enig482EE4716ADE3E02B0F76929
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFFNtJp/pqN2EBUqwgRAhWeAJwLsLX1bFrugnz6IEwuskmzrkuPhQCfSHmZ
TYfQHtW2lV2IIot9KpAi8Pg=
=zb+c
-----END PGP SIGNATURE-----

--------------enig482EE4716ADE3E02B0F76929--
