From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Thu, 15 Feb 2007 16:07:04 +0100
Message-ID: <1171552024.5220.4.camel@johannes.berg>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
	<200702100655.51495.mb@bu3sch.de>
	<1171459090.11116.22.camel@johannes.berg>
	<200702142240.01494.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1066168374=="
Cc: Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <200702142240.01494.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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


--===============1066168374==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-n4SadKywi06ow99jC/ry"


--=-n4SadKywi06ow99jC/ry
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-02-14 at 22:40 +0100, Michael Buesch wrote:
> On Wednesday 14 February 2007 14:18, Johannes Berg wrote:
> > On Sat, 2007-02-10 at 06:55 +0100, Michael Buesch wrote:
> >=20
> > > It's likely that old cards still work with v4 firmware,
> >=20
> > No, it's absolutely impossible. Rev 2/4 cores have a totally different
> > instruction set in the microcode.
>=20
> Ok, I was not talking about _that_ old cards. ;)

Are there cards where they have new microcode instruction set but no v4
firmware?

johannes

--=-n4SadKywi06ow99jC/ry
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF1HcY/ETPhpq3jKURAltLAJ9pXbGsv9jjJUxZBadM4mH3GmIh0QCghEeg
k7mggP2BMJ1QhArpNu/P4eE=
=i0g8
-----END PGP SIGNATURE-----

--=-n4SadKywi06ow99jC/ry--


--===============1066168374==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bcm43xx-dev mailing list
Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/bcm43xx-dev

--===============1066168374==--
