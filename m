From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Tue, 18 Dec 2007 15:16:12 +0100
Message-ID: <1197987372.4885.160.camel@johannes.berg>
References: <1197483844.6558.158.camel@johannes.berg>
	 (sfid-20071212_182419_921972_853D21C5)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-SfUyMZAEGa3WRSgR9/mx"
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jouni Malinen <j@w1.fi>
To: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1197483844.6558.158.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20071212_182419_921972_853D21C5)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-SfUyMZAEGa3WRSgR9/mx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Wed, 2007-12-12 at 19:24 +0100, Johannes Berg wrote:
> [comments welcome. I really need a refresher on what the frame formats
> mean but I think I did the right thing with skb->protocol here, I also
> think we had a bug with rfc2042 header frames bigger than 15xx bytes and
> eth_type_trans()]

I just discovered annex M to the 802.11 standard, will recheck with that
in mind.

johannes

--=-SfUyMZAEGa3WRSgR9/mx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2fWKqVg1VMiehFYAQL35xAAkrjdujbPtTt2VoRG3U0kqFg1CP89jj/t
5wz8SDFOrJTwx6QW/3VBtOUGkUNlVXJzik935b1bktS3uZeXBQTzhg8vuPbgncn/
vyS3xcK+c5zdWvsPGBjcMquc31BTu0js+Y/RXkGLvhDOFvfyXoFJY54k0UvlZK8z
1/FnaLykAs25klTLxuOFqf7fft7BziN8WjQnqX17s40jeZTmNcejftmbY1DCVpY/
oZfh5pj+d9M2cRIVYHtLEwnueTe/fnkaeT/XtobwTxuJt8J7p+1Qj5qVCxMOOf5s
jSIy9E66VnyxkfroxxxvqgRSk7iWixvjmLCGx5dUnktXKsXd/Xo/0w0YelcDyttI
Sq2cBNtZAEkRTd3zsDZCV+kRspl7g0Jwv22KygVQUCaXlY0CliK6rakMtazxBQjZ
G5SeliXniXbTKCREPfDh8heC374vhEOlvPLRlenCCAbZKvbC8bR5dUbuUMRXRTwF
3KoUJeOdXqJ84yNPM1sMGr1q4pHH3mmnNiykRPjXd5Wn1ZhyjNmRkULOrRpJAyvr
UrCgflYS2H9V8DFGa09Xxj0+RVN+WqpgLtBjaYBdNJt4SZErR7aJ0Hx+ZWbd1rIR
0gIcbc27CglWRrITZwlEZJAP9oZrIUOSBitMhnhBotJ5BGE8PFBWygXqCIrR6YiG
gZ0I+iaQgCM=
=u/xz
-----END PGP SIGNATURE-----

--=-SfUyMZAEGa3WRSgR9/mx--
