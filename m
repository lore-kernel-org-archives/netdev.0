From: Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device propertieswithrfkill_gpio
Date: Tue, 26 Jan 2016 09:52:08 +0100
Message-ID: <7911934.5tJp6vWQjI@fb07-iapwap2>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com> <1626364.s6q6eBGYVQ@ax5200p> <1453798016.2759.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1679971.baOqhhWpfy"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453798016.2759.5.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1679971.baOqhhWpfy
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"

Am Dienstag, 26. Januar 2016, 09:46:56 CET schrieb Johannes Berg:
> On Mon, 2016-01-25 at 21:59 +0100, Marc Dietrich wrote:
> > 
> >
> > seems to work fine. I wish we could instantiate this from device-tree
> > so we can finially get rid of this file.
> 
> That'd be nice - anyone want to propose rfkill DT bindings? :)

There have been at least 5 attempts to do this in the past - all fail. You've 
been warned :-)

Marc


--nextPart1679971.baOqhhWpfy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWpzO4AAoJEKyeR39HFBtoXMUH/2IE8u7/Fj5UBqUr0fi+qyFV
6UxTjBv90FooFukmOpmJuU3yKeGO5TFfK+W5uZ80GtO7lySjw28Ugw8i+t03uCBi
Vu6Lgh1oRBWghiucwKvFVlmyz1ZqonIZ53swQ3fAk1INX2qtcTyKVQigJy/3yEFR
mFBcpS6q4I8QnUe1sZseB9JUPD/Fu7E3H6xOXQyDVwXy9VwhWRyc7huAoZIvlkHH
b14fXokls7fsKIJa6FFFZPEtRvyBpbki1xcoxMq1NJYFWep1hq50yj+9BNrBAkPv
5PUGxaBm6rRv0epgc4pFt+P/fJikTCcATcOnp+iQBRgMozXn4J39qwJ6F9k/HP4=
=I/ky
-----END PGP SIGNATURE-----

--nextPart1679971.baOqhhWpfy--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
