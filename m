From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sat, 21 Mar 2009 13:09:35 +0100
Message-ID: <1237637375.5100.178.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com>
	 <1237537967.5100.135.camel@johannes.local>
	 <b6a2187b0903200304l469e3eeet87c51b1cddb43ea8@mail.gmail.com>
	 <1237544033.5100.143.camel@johannes.local>
	 <b6a2187b0903200914r23d635c9obc55b30b7cc04382@mail.gmail.com>
	 (sfid-20090320_171427_332673_B71D0D63)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-yoAsfB/ad+FmHrXW6y3a"
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b6a2187b0903200914r23d635c9obc55b30b7cc04382-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20090320_171427_332673_B71D0D63)
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-yoAsfB/ad+FmHrXW6y3a
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2009-03-21 at 00:14 +0800, Jeff Chua wrote:

> I went back to 2.6.28 and found out that I could associate as follows
> (but this would not work in 2.6.29-rc8 ... should work with the
> patch).
>=20
> modprobe -r iwlagn
> modprobe iwlagn
> iwconfig wlan0 mode Managed
> ifconfig wlan0 up
> iwconfig wlan0 essid "xxx"
> iwconfig wlan0 key restricted xxx
> iwconfig wlan0 ap auto channel auto
> iwlist wlan0 scan >/dev/null

Thing is that this works perfectly fine for me, on very similar
hardware.

OTOH, maybe it got _fixed_ again. Would you check wireless-testing
(http://wireless.kernel.org/en/developers/Documentation#wireless-testing.gi=
t) for me? Or compat-wireless (http://wireless.kernel.org/en/users/Download=
)

johannes

--=-yoAsfB/ad+FmHrXW6y3a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJxNj9AAoJEKVg1VMiehFYtR0QAKTf7xrImi8vzq3looDokqgF
Ky/+xH06/PRSf8VxeB89SSyridRagfky1jalBbx08lpYMD9qQoX9GI92oOJ6JZkk
trIFHnhtKegYG0+ff95gjqstCsaEY6XFSNLthTfshv5UMfILjmy6QsAjCLbICeLd
dfuDoB2Rg1/5pRi59Hr7s7DNHeTk1ieOy/2jNgoFpfJZEvElD2zVxFZ9j9gFN8Ny
yx6IrtnfHTAEyL223RGv87dXp8f//jFlW6/tiJUbvZZDiG8K8qnPVIvNaaTZ8AtW
QSYAG0Sao59E8qwJ3h5UQpOaB0Gt4vplBVjfxtEO4xXllztE7j9dHVjRcRiN/dZb
FdtN1WnRw2cgpInGcIf9Mwvds1dcINfIy2W2jpjymNFN7ZX6r84OqoDjGa1Z7bgG
s9imYFoN/orXewS5er4gvWi8lQhMMoQcIc3dw+po0t9NthwxPW/SaDKJ+BPuX4Ut
GFKVRExTGUFrrR2H9fzrAd0N7Q1d2UBxDXICIzncymaOjWTMrpMwHT5TT67A/7Xy
+VqRypXBgsr/PlMWt+INgCUpuC4armFAXV6h6W0KLBfQz4QCWNdAEijxGYAI8N10
YCvUB+fRiIgqnneMMp2uFx8VowxDIk5IAdnFwq/sMUvfmw82ThS8GOXl7sNsIqIn
GVY6emMiE3Ez2ayNZNj+
=P6f9
-----END PGP SIGNATURE-----

--=-yoAsfB/ad+FmHrXW6y3a--
