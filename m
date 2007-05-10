From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: support for bridging ethernet and 802.11
Date: Thu, 10 May 2007 19:19:35 +0200
Message-ID: <1178817575.3806.36.camel@johannes.berg>
References: <CCA1D7C0-D44A-450D-A76E-DAE792E0CB37@kernel.crashing.org>
	 <1178816781.3806.31.camel@johannes.berg>
	 <20070510171213.GD24712@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-nKaMrXWUmLmwEwt2cFx0"
Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070510171213.GD24712-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-nKaMrXWUmLmwEwt2cFx0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-05-10 at 10:12 -0700, Jouni Malinen wrote:

> IEEE 802.11 allows only the own MAC address to be used as the source
> address (addr2) when operating as a non-AP STA in BSS (client in Managed
> mode). In other words, layer 2 bridging does not work properly. AP mode
> and WDS links can be used for bridging without problems, but this will
> of course require the driver to support these.

Ah forgot about that, I had only thought about AP/wired bridging. How
would the prism driver actually do bridging in STA mode though?

johannes

--=-nKaMrXWUmLmwEwt2cFx0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGQ1Qn/ETPhpq3jKURArwUAKCfY8Q+izvfWWc4tskc55j2fD1kMACgmEHd
AqI1LFxfFKq4a0LhZKfiEy8=
=R2cc
-----END PGP SIGNATURE-----

--=-nKaMrXWUmLmwEwt2cFx0--
