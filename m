From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix for oops on resume
Date: Wed, 07 Feb 2007 14:54:50 +0100
Message-ID: <1170856490.6798.40.camel@johannes.berg>
References: <45c8bd59.oamnvaNRMZvKoPBa%Larry.Finger@lwfinger.net>
	 <1170850549.6798.22.camel@johannes.berg>  <45C9D2E1.7040906@lwfinger.net>
	 <1170855150.6798.38.camel@johannes.berg>  <45C9D930.5010307@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-9jRpBJcTCvtAsdp1bUZa"
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45C9D930.5010307-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-9jRpBJcTCvtAsdp1bUZa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-02-07 at 07:50 -0600, Larry Finger wrote:

> Could you please apply this patch and tell me what gets printed after you=
 resume, and whether you
> did a suspend to RAM or disk?

Not a bad idea. I can test suspend to ram as well as to disk, just got
both working again.

The kernel I'm running right now was built on my powermac so I can't do
it right away (otherwise I could've just recompiled the bcm43xx module)
but I'll do it later today or tomorrow.

Usually, to get my connection back after a suspend, I just have to set
the ssid again.

johannes

--=-9jRpBJcTCvtAsdp1bUZa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFydoq/ETPhpq3jKURAgBZAJ49QdaU3ysezdokLHtd7ZVAjQTVXQCggfRn
0mv6T4AgFAjAqjVV5BkIC6o=
=D62B
-----END PGP SIGNATURE-----

--=-9jRpBJcTCvtAsdp1bUZa--

-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
