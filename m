From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 08 Mar 2007 23:36:12 +0100
Message-ID: <1173393373.3831.23.camel@johannes.berg>
References: <20070306171316.GA19669@bougret.hpl.hp.com>
	 <200703061943.07350.mb@bu3sch.de>
	 <20070307020310.GA20466@bougret.hpl.hp.com>
	 <1173364747.14001.7.camel@johannes.berg>
	 <20070308184954.GA24485@bougret.hpl.hp.com>
	 <1173382042.3248.63.camel@johannes.berg>
	 <20070308193412.GG23040@devicescape.com>
	 <1173382802.3248.68.camel@johannes.berg>
	 <20070308221128.GA24884@bougret.hpl.hp.com>
	 <20070308141756.efdfd6da.randy.dunlap@oracle.com>
	 <20070308223058.GA24960@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-A0ugIXUNFx7kSjNbWe1s"
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070308223058.GA24960-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-A0ugIXUNFx7kSjNbWe1s
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-03-08 at 14:30 -0800, Jean Tourrilhes wrote:

> 	Then, I assume that the powerpc64 must be using a magic
> version of iwconfig to configure wireless interfaces, because I only
> ever got one other bug report on the issue. They should have sent the
> patch to Johannes, because now I know about their unauthorised version
> of iwconfig.

There probably aren't many powerpc64 users that actually use wireless on
it since, well, most such machines are pretty stationary and
well-equipped with gigabit ethernet :)

May I ask who this was though? Some distro?

johannes

--=-A0ugIXUNFx7kSjNbWe1s
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8I/c/ETPhpq3jKURAhHRAJ9Ye0K+KXMJmOEr685gXO6gIP892wCeMbrk
9SIHHbbFdMPTffn+6q6Cs5A=
=cd6K
-----END PGP SIGNATURE-----

--=-A0ugIXUNFx7kSjNbWe1s--
