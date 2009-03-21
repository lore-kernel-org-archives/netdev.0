From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sat, 21 Mar 2009 16:11:54 +0100
Message-ID: <1237648314.5100.220.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com>
	 <1237537967.5100.135.camel@johannes.local>
	 <b6a2187b0903200304l469e3eeet87c51b1cddb43ea8@mail.gmail.com>
	 <1237544033.5100.143.camel@johannes.local>
	 <b6a2187b0903200914r23d635c9obc55b30b7cc04382@mail.gmail.com>
	 <1237637375.5100.178.camel@johannes.local>
	 <b6a2187b0903210808m7586fdc2g53e72aa269d6e353@mail.gmail.com>
	 (sfid-20090321_160814_154410_54F18AB4)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-wsp6Ah0OsJizFKNMyiVh"
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
In-Reply-To: <b6a2187b0903210808m7586fdc2g53e72aa269d6e353-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20090321_160814_154410_54F18AB4)
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-wsp6Ah0OsJizFKNMyiVh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2009-03-21 at 23:08 +0800, Jeff Chua wrote:
> On Sat, Mar 21, 2009 at 8:09 PM, Johannes Berg
> <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> > Thing is that this works perfectly fine for me, on very similar
> > hardware.
>=20
> I've set hidden SSID + mac address filtering (only allow my notebook
> MAC address) as well as 128 WEP. And no problem to associate with
> non-hidden AP.

Ok, I haven't tried WEP or MAC address filtering, but I don't see how
those would make a significant difference. I can try again, but not
before mid next week since I'm away from my test machine.

> > OTOH, maybe it got _fixed_ again. Would you check wireless-testing
> >
> (http://wireless.kernel.org/en/developers/Documentation#wireless-testing.=
git) for me? Or compat-wireless (http://wireless.kernel.org/en/users/Downlo=
ad)
>=20
> I'll try that tomorrow. Seems a lot to pull from git.

Thanks, I appreciate it. You should be able to cut it down by using
--reference /path/to/local/linux-git-tree or just compat (though I would
recommend using the git tree). I've also tried to go back to the
versions you were testing before and had no problem.

johannes

--=-wsp6Ah0OsJizFKNMyiVh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJxQO3AAoJEKVg1VMiehFYCFUQAJTYVdeOgp0SuFPVXy3RcK7b
r+3GE/yHrE9aurZJhu9N2hKYbVupSNcYQoNjWei/VIaCReERXY+tH4atHAYS+hfM
Lp1myudOHsNw0Iz2v5q8RY0EzVQ/PHsCeFPgB983zpmcJVjMN4ywVrdQOe4p6fyU
2EQS8F0PokZTi+9H6599LiAsQ9kip/aOMquxtBRzVuOsqGwdM2u8Riy4pPg8pu2p
uXNVPI3PjqmvYIGLKFN4rZ0/G+4bLeV3ua9Fxpy9kz4ILAyq4sLwMmcywrH+ibUU
3rqi7+1fnTJQRI4zc6+JdDtwEjr0ltKGb6qlzIvK9hrZAWAVtLbbAoo287k++W2x
J+FLxrkg9tmihBxsrgGPdAsxYDIDlSL0gk4om3qLuvQv1msNyxeOoS8DgNRxVsRG
hywwAWrdg24WIicREZkbcJNOlaZDjJnYpXhEEXJXLd4YxG0NZ6KD0nAMw+ZwKIqe
G0NjQh8nsK8zwc0Db/sBUzpg7bZVM707Da0GfiSDQNvd4Z9xNxlTAfCAM1zyCpmg
twhX6BrZIZ8tK+eA4rhImw/I0tzSLzHQJbFGW4Y5sIawK5/JYTpRfxnRgDybLJsX
x2t8K9ReCMRyhmhyCzRdr/yY8UfbAIUdM5CmqW5oChZXvtkrRib1s9j+ACF7qqVV
/Ol2j0WfDv7sv66+L5Uj
=k+mW
-----END PGP SIGNATURE-----

--=-wsp6Ah0OsJizFKNMyiVh--
