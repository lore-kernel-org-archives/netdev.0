From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: oops with recent wireless-dev tree
Date: Thu, 30 Aug 2007 17:01:31 +0200
Message-ID: <1188486091.3978.32.camel@johannes.berg>
References: <20070829223752.GA6969@seehuhn.de>
	 <1188475530.2963.20.camel@johannes.berg>
	 <20070830074949.7cd25b04@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-msTEZMDPb3e8RRSHWxSV"
Cc: Jochen Voss <voss-52ZyvxujusuELgA04lAiVw@public.gmane.org>,
	linux wireless list <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, bridge-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070830074949.7cd25b04-s08KbqtN0aBORcJjwVk88+YtYHrY8QCHmKZK+fsXvFM@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-msTEZMDPb3e8RRSHWxSV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-08-30 at 07:49 -0700, Stephen Hemminger wrote:

> Devices aren't required to have ethtool_ops. The code there used to
> call ethtool directly, and it would handle the error cases. I'll rollup
> a fix this morning.

Great, thanks.

Jochen had a patch: http://marc.info/?l=3Dlinux-wireless&m=3D11884271502661=
4&w=3D2

johannes

--=-msTEZMDPb3e8RRSHWxSV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBG1tvL/ETPhpq3jKURAok+AKC7kBAPAr/8QsVZ/N4g9POGLiK2ZgCfdXBz
D2Zv2GZuwyXdQUg6iphWb14=
=wpiP
-----END PGP SIGNATURE-----

--=-msTEZMDPb3e8RRSHWxSV--
