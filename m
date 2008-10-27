From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCHv2] printk: add the %pM, %p4, %p6 format specifiers
Date: Mon, 27 Oct 2008 20:47:30 +0100
Message-ID: <1225136851.3796.53.camel@johannes.berg>
References: <1225067465.5672.1.camel@brick>
	 <1225090765.3746.7.camel@johannes.berg> <1225124904.5440.1.camel@brick>
	 <20081027.123805.134354592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xvJsigOVXpAnx8KLyMip"
Cc: harvey.harrison@gmail.com, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37214 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbYJ0Trk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 15:47:40 -0400
In-Reply-To: <20081027.123805.134354592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xvJsigOVXpAnx8KLyMip
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-10-27 at 12:38 -0700, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Mon, 27 Oct 2008 09:28:24 -0700
>=20
> > On Mon, 2008-10-27 at 07:59 +0100, Johannes Berg wrote:
> >=20
> > > Also can you keep mac/ip address patches split up so we can use my
> > > version of the mac address patch (it's already well-tested)?
> > >=20
> >=20
> > Sure.  I'll build on top.
>=20
> So I'll wait for Harvey's "v3" of this patch, and once I have that in
> the net-next-2.6 tree I'll start adding Johannes's conversions on top.

Ok, fine with me too. Harvey, can you sort out the ip4 issue and then
send with %pM included?

johannes

--=-xvJsigOVXpAnx8KLyMip
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBhrOAAoJEKVg1VMiehFYrRsP/14t7fcbcpPxmZtVU9arVnaB
+/SwQFXgo6kRuBKSP3uNirtqT0Tld2R3LlFUiTyPdwYKPc4tu+pXEbSdKP78wWur
IlBVgw/VpOEmBaotJY04btZfxHvSBTjDuJb4DU7rCvN9VBtguR2iMdWJTvpdP+m1
WFrBoVDMtnFq9OyazALpifnrXQk0xv/K4v+u4BHDp3gP64hmVso4yRBFjQthO6l4
dBjGUueNk486YRtC//AbFczyXb9VWngMQPsmbhoQHNG0oPHe2IJ6R2YMKq/z2nqU
vSFlZCfwVHVjxm75NZW7inlikuAaWzvkPFWj0zY+Oqrp6f0hmOcHdMszS2igybXo
/HgqDuddRJKR8fogBN0n0EGHKidx3DIofeHvn3UYZvHN2tor6rJHIU8OZc0t3vMg
Y5XQ3iXgU+0wY+7QFjctewHZtmAHRJD0a2BPfeky3OsGQPzYEE5e19OxGlYNH8wu
KGUkONoMhsvVd9LQCObWNmbKwD2RhEPIbAkdTxid3vm49o3GTtxyzD5YL2Lq04ta
J/HUYAf+S55GkKCx7CchHbEFpm5W0zbFPWethMHcLzW42Osa9vWaLFLyNaPJkAwW
HCIpGqzGGCP7bpeW1VQmw8ICwwFQI2vXMCjCck/JWZH7wysD3bJwBFhubBLujh3A
ikfb4hFcQdACxSgYlRA9
=rxcQ
-----END PGP SIGNATURE-----

--=-xvJsigOVXpAnx8KLyMip--

