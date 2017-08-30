From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [GIT] Networking
Date: Wed, 30 Aug 2017 11:48:23 +0200
Message-ID: <20170830094823.GA31503@amd>
References: <20170815.175219.753462032002961032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, kvalo@codeaurora.org,
        xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170815.175219.753462032002961032.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

Could we get this one in?

wl1251 misses a spin_lock_init().

https://www.mail-archive.com/netdev@vger.kernel.org/msg177031.html

It seems pretty trivial, yet getting the backtraces is not nice.

Thanks,
   	 		     	     	 	       	   Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmmiecACgkQMOfwapXb+vJSdgCePIoHb+VmGHSPeaVsYV7YQLTr
emQAoJZssZlcj44QAT3WwMPFGuDqrsai
=pL+G
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--
