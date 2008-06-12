From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] Do not activate promiscuous mode on wlan interfaces for
	bridging.
Date: Thu, 12 Jun 2008 20:44:10 +0200
Message-ID: <1213296250.3730.33.camel@johannes.berg>
References: <1213232760.6645.24.camel@localhost>
	 (sfid-20080612_030607_332834_1EFDE126)  <1213255570.3871.8.camel@johannes.berg>
	 <1213294793.6615.16.camel@localhost>
	 (sfid-20080612_202000_504292_98E93460)  <1213294852.3730.31.camel@johannes.berg>
	 <1213295643.6615.20.camel@localhost> (sfid-20080612_203408_119945_EA437275)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rKWwzpBvGHd/yxjrX7Cw"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	j@w1.fi, bridge-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Luis Carlos Cobo <luisca-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1213295643.6615.20.camel@localhost> (sfid-20080612_203408_119945_EA437275)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-rKWwzpBvGHd/yxjrX7Cw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-06-12 at 11:34 -0700, Luis Carlos Cobo wrote:
> On Thu, 2008-06-12 at 20:20 +0200, Johannes Berg wrote:
> > Is this a mac80211 driver? When are you activating promisc?
>=20
> Yes, libertastf (adaptation of the libertas driver to use a thin
> firmware and mac80211), you can check it out at=20
>=20
> git://dev.laptop.org/users/javier/libertastf.git
>=20
> Still want to polish it a bit before submitting.
>=20
> Promiscuous mode is being activated when attaching the interface to a
> bridge, in the lines included in the patch on the first mail in the
> thread.

But in response to what mac80211 command are you sending the promisc
mode to the hw?

johannes

--=-rKWwzpBvGHd/yxjrX7Cw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIUW53AAoJEKVg1VMiehFYOPoP/ix6ZwYtBUAnb6gZv1oXoZS+
UuSBhWUjaVWM/1TBt5KOtLcmGdMGFt4RM4kWeZlBKIep9fWFfc6Odw/wipS6v7pU
lovcVYkI4sZpc1YHqBFCiPZaSBR5FFrmug1CdNjghopxb3aKZJIbBhRjnZ2om/0C
LaqulsRdgkCZ6Rxu5JCfJ3SFhLcNaOsWy8wHLAIgLIKTi6h/xfQsxIoEzJAFT6s4
5n+qPxqDfGj40RIJ7WB13hYAOWKWaSNBsNsd1qMjf6+BnkbJQoB4B8lUgV+X7EAY
l+OemYjVjHBtfdp68zMI5KC+k4bIGAqqib/HEdYGdjCjneQTPBwP66JQemBX/Z8o
26kN8gg88rWMagOqPESD13ZtZ9517RGmvx4+w47n6TLHzhHdwj40Ujk+LTVa/v36
5ia6S9qNrHbfyMVxP04y8WzXWcVgnLTvdY2tWAxp8c25soeMNb5/CLAFl3pd1iCH
rCEMdY7zch/zfWqfxvZQVKMk+v8DlnwHzbHTbQVYVhOI1YImHj79LdIQogsrgMUB
eZi8vYfrwITROizIXFzf/TOBQA4huSQcd0clk938DfjAhhjBt0FmITdo+Q3YCFci
xUHdTJuRw0ZSHU2sDMvDG9sIcGN42Vzs864QJ21t4wB6OUyciLmLmfiHSnRL35e0
jZu5N1hwgnw35GuhQcU7
=yMx2
-----END PGP SIGNATURE-----

--=-rKWwzpBvGHd/yxjrX7Cw--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
