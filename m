From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 4/4 (optional)][MAC80211]: Brush up error paths in
	mesh_path_add.
Date: Tue, 06 May 2008 16:58:00 +0200
Message-ID: <1210085880.13316.31.camel@johannes.berg>
References: <482070F7.5060506@openvz.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-T6T++Bww5nLxlKtqwALa"
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Luis Carlos Cobo <luisca-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <482070F7.5060506-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-T6T++Bww5nLxlKtqwALa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-05-06 at 18:53 +0400, Pavel Emelyanov wrote:
> There are already tree paths, that do incremental rollbacks, so
> merge them together, rename labels and format the code to look a
> bit nicer.

Looks all (all four patches) good to me, Luis?

johannes

--=-T6T++Bww5nLxlKtqwALa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCBx96Vg1VMiehFYAQJdjg//VddMnzqzgfBxtREnsl3utB/WzX9167DZ
IB6zq1D27UBoeslRp/kR2nxrAxmFFHMbzYlzXxYrsNXgag8ydF0JQoQcRNeqOI+q
ROz0nqFyq4cX785kop+BiIZ0La/oQa0i9IrSeSqoCS6mE15s9FfJaO+VM9gkKI3r
sh8vlM5214tjzVkjZxHiNf0hXeGVaJAt0NvAnqg8UFVRXSdZDrdue4vLtwe+IP6W
/NlYNHKdolWBQWNzWt4xokT5zC4sbSH7ngg8JQrvDUDyIgL5t3Y4l/wP2AxI6+ue
JTXu5xPvI9yybG69UTriMQNQaThmfibEXcndCZ5gbqqkHpnE3y/hHz75yzI5xVrT
drQf1sQaFe0smJ+xFZYR7H8lXuthMhV3E1o4NXEuNtGnITVnQ5ffVpngO0LDBynG
8NauAGybHecj2YF0b0yzLcFvDpeOfoM9AcaAsfcz0yXMjOKollrryPzHjY/Zyd8y
ft2D5Z8XW8OhdfKEiEMNIfyn4+yANP9wWFmznfKSkDx9T66YFIT/aWCEqo+Ue3uV
a+hiY4nKL8gttwM+mHxrTKW+asr74v4P7f0GrRIMOn+KSZya3duw8A9RbDeropj9
5mK3Jbt2ujNr4LjDhIwz8dRXIW79QO+9s2gPeFUtPfReRichUW/H42nZIwx+BcMw
v6YkcmUYlWU=
=iMwS
-----END PGP SIGNATURE-----

--=-T6T++Bww5nLxlKtqwALa--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
