From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix for oops on resume
Date: Wed, 07 Feb 2007 14:32:30 +0100
Message-ID: <1170855150.6798.38.camel@johannes.berg>
References: <45c8bd59.oamnvaNRMZvKoPBa%Larry.Finger@lwfinger.net>
	<1170850549.6798.22.camel@johannes.berg>
	<45C9D2E1.7040906@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2059228793=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <45C9D2E1.7040906-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============2059228793==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-dW6QAIV0t5HDZ8bF3dEP"


--=-dW6QAIV0t5HDZ8bF3dEP
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-02-07 at 07:23 -0600, Larry Finger wrote:

> As you suggested earlier, a slow clock setting in the bcm43xx device may =
be the cause of this
> difficulty. If my laptop would suspend/resume correctly, then I could tes=
t various fixes based on
> that hypothesis.=20

Mine does suspend, but I don't see the problem...

> Since it does not, I think the band-aid approach is warranted.=20

Oh yes, I agree, having some hardware mess up will almost always crash
the computer anyway.

> A proper fix is
> still on my agenda; however, getting full data rates still has priority.

Sure. Thanks for all you're doing :)

johannes

--=-dW6QAIV0t5HDZ8bF3dEP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFydTu/ETPhpq3jKURAij5AJ926Vy+3KkRX+/OBFRO9cbSutuCFACfYiNq
kazZr+6i5YprEP/M5Ane0c4=
=uRTI
-----END PGP SIGNATURE-----

--=-dW6QAIV0t5HDZ8bF3dEP--


--===============2059228793==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bcm43xx-dev mailing list
Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/bcm43xx-dev

--===============2059228793==--
