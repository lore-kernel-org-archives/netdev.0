From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 25 Mar 2010 15:48:47 +0200
Message-ID: <20100325134847.GB3471@swordfish.minsk.epam.com>
References: <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
 <20100316182619.GA3451@swordfish>
 <1268765284.2932.17.camel@edumazet-laptop>
 <20100325113038.GA3471@swordfish.minsk.epam.com>
 <1269523180.3626.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tsOsTdHNUZQcU9Ye"
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55662 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625Ab0CYNrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 09:47:42 -0400
Received: by wyb38 with SMTP id 38so3473033wyb.19
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 06:47:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1269523180.3626.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (03/25/10 14:19), Eric Dumazet wrote:
> > Eric, I think you can put Tested-by: Sergey Senozhatsky <sergey.senozha=
tsky@gmail.com>
> > on the cumulative patch as I don't see any errors with pktgen over LAN =
testing.
> >=20
>=20
> Hi
>=20
> Thanks for the report. Problem is I am not confident enough on this
> driver.
> I believe Fran=E7ois Romieu is the one that can possibly push a patch ?
>=20

Thanks.

Hm. Fran=E7ois' patch introduced new 'problems'/'stack traces' with pktgen =
testing...
Fran=E7ois, any comments?


	Sergey
--tsOsTdHNUZQcU9Ye
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkurab8ACgkQfKHnntdSXjTdPgQAq5rrA06+7+6R69leTbRkQl8l
9jlk/7GpSmeMjD+dWW3Wh0eJCSG/mWpjGjG+DigTbjLBFZVaMHp7ZFAvkjygaMsO
UcWaHCi0SRXf4/9ibDt5vOQfwn9fEWyHapQJPaGSARW0M2d5ywSMs6kBm6ahVVv7
q4nX3m56k8ICHcErntE=
=YZAT
-----END PGP SIGNATURE-----

--tsOsTdHNUZQcU9Ye--
