From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Fri, 13 May 2011 05:04:37 +0100
Message-ID: <1305259477.4065.405.camel@localhost>
References: <20110506171249.GA29942@uio.no>
	 <1304761486.2821.945.camel@edumazet-laptop> <20110507095910.GC30492@uio.no>
	 <20110512.155221.59681200.davem@davemloft.net>
	 <20110512225458.GA19573@uio.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-xh3nO9SiircDHBJsnIG6"
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yoshfuji@linux-ipv6.org
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53524 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750791Ab1EMEFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 00:05:24 -0400
In-Reply-To: <20110512225458.GA19573@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xh3nO9SiircDHBJsnIG6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-05-13 at 00:15 +0100, Steinar H. Gunderson wrote:
> On Thu, May 12, 2011 at 03:52:21PM -0700, David Miller wrote:
> >>> I cooked for you the official patch and made sure it worked with a RE=
D
> >>> ECN setup, and one ipv6 tcp xmit.
> >> Great, thanks :-) This looks good to me.
> > Applied, thanks everyone.
>=20
> Do you think it would be possible to get it backported to stable kernels?
> (I've been told getting it into the 2.6.32.x series is the easiest way to=
 get
> it into Debian stable, and I guess it should be a candidate.)

If this doesn't apply directly to 2.6.32 then you'll need to prepare the
backport and send it to stable@kernel.org with a reference to the commit
in mainline.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-xh3nO9SiircDHBJsnIG6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATcyt1Oe/yOyVhhEJAQrNbBAAw48hOSInQQ9Hp/yU7FhftLQQxC29awo1
dCqTl+t6U5ZFpUnCVxJ3gy/TjtZrsyTbRPEzaiQz7bR8McPjEEVAOY2e5cqt968Q
Pg1hGn42+Kg5nezsCc63XvKlhgQwdQ3JT4RpjuG6W5P1NesSgL9cdeV3Bo5KYMtm
RDDwKvhNjTNEyuwk6BQG5A/Gj3CmRUWi+LChuenDaE3IGIZbU0Iar9NhiU08i3XC
PRQS1sZtrlmt1RiUl7XxKt+ZsoI3fpcWLLYQuNUbRmlXDfRN5OosJaftGxLaq5AM
LonWc+NjwlvERjkmbLQ9akDoxXoMqcDODWeWUg3RmsZ+Vmi6nL/f5sr1JYk1skWa
EISXgLz9bhf8h4oL9YMNyUQEwgMTKkc3lmf8IzCVrHULMWO+1ZwieWUXBKKJ5yWQ
ItQ4Hlwu0OFX80hY1AkEVSUyxXmDM8Rj3hhNPGEaHndgrtw6rYfwl7P4rNzRt69B
BY7EhMvx2uXC6OymiiyxopZVLraSRKDT/o1wMESN2tYbVPsCUvWoKvAOWnPcT3wC
T4hHnEbTijShn7Dxq50Ifj7wT2jogs76wglCRmGD/JsTZ8UX9eGcjb5nOfK5LjsP
+FELODoIkosW4r0IchUv5icfJcJt8D0thtPHJjaomKrJwnOaTVrTMl90Flvln553
CUYZoxP8FZk=
=mOFh
-----END PGP SIGNATURE-----

--=-xh3nO9SiircDHBJsnIG6--
