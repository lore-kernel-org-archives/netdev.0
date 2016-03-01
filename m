From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] ethtool.h: define DIV_ROUND_UP for userland
Date: Tue, 01 Mar 2016 17:14:06 +0000
Message-ID: <1456852446.3098.157.camel@decadent.org.uk>
References: <1456845641-6985-1-git-send-email-nicolas.dichtel@6wind.com>
	 <20160301.114232.138387157898713379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9i3fC7UkNlar6eyD7bNM"
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	kan.liang@intel.com
To: David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45640 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751273AbcCARO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 12:14:29 -0500
In-Reply-To: <20160301.114232.138387157898713379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9i3fC7UkNlar6eyD7bNM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-01 at 11:42 -0500, David Miller wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue,=C2=A0 1 Mar 2016 16:20:41 +0100
>=20
> > DIV_ROUND_UP and is defined in linux/kernel.h only for the kernel. INT_=
MAX
> > needs limits.h in userland.
>=20
> It is wrong to provide a definition of this in the user visible global
> namespace.

Which is why he's not doing that...

Ben.

--=20
Ben Hutchings
If God had intended Man to program,
we'd have been born with serial I/O ports.
--=-9i3fC7UkNlar6eyD7bNM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVtXN3ue/yOyVhhEJAQoLwg//dlzXL49ePzWYD8vAPN8VwudwiordYMDk
+gZm3tTioqHgngCmJNQP6bfZOb79gs3sWdZJROdn4BvVNYRFq0gl4CjFREJvq2d8
AFY/NiUUdXOhQLWtt9dGLm0sPCIQCj/EGG2wsYzwcQ2k/T7xrbx1hsWZ42T3Cuxd
hsNA4rohkYsw2KR7YsDfzoApPNnfxqDzSTPk8eTc67RBIPEGN//Ne7N56vXGyz9B
iYQJwaSqREw+awj/1K2nTd+B6mq+RNf0AeWP4NxiokMFjazIHH0ZEb5kDRFnnK6+
vJZb2BAba9qooTu6dzE0NKbuWqut7bFy89uCiohSimkm0z2PvwPTvebr7u2rdAGF
fI9j2rCs072hPaIsSugrL432izPGuFEdgyDLUQvnAGqOjIAyTmQMRZbQQ1MBIYBG
J2LXXNFLYxUIbz7CF64T7JgdDalVscF90hDi0zhT8Mavx8AxviclxFemyOVdmxMP
XdE/FYZolbs1qA3cFTkhEsNU2a+vZu1NvVzr2vcgvTjnssfIYUO2qi2YcHPuza4z
TwSpzvcwZl+8rPXTh/LGLmLNeQ55lv/4VqKWuuZW4+1icgeaZtvgWiKw/4Bumvqg
0L80AuVumlfUiaNVKR79nGFVMq9E0Gpvp5RZlsgvI7a2hf4vPKjHAfNecqxc/fxg
TefYPE3Dq6I=
=rNhU
-----END PGP SIGNATURE-----

--=-9i3fC7UkNlar6eyD7bNM--
