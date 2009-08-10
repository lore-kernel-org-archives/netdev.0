From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 2/2] ieee802154: add virtual loopback driver
Date: Mon, 10 Aug 2009 16:29:16 +0200
Message-ID: <1249914556.32614.14.camel@johannes.local>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
	 <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
	 <1249913800-10176-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-OL0+UHPAPoGPd5SY+Ubc"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1249913800-10176-3-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-OL0+UHPAPoGPd5SY+Ubc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-08-10 at 18:16 +0400, Dmitry Eremin-Solenikov wrote:

> +if IEEE802154_DRIVERS && MAC802154
> +config IEEE802154_FAKELB

depends on

> +	tristate "Fake LR-WPAN driver with several interconnected devices"
> +	---help---
> +	  Say Y here to enable the fake driver that can emulate a net
> +          of several interconnected radio devices.
> +
> +          This driver can also be built as a module. To do so say M here=
.
> +	  The module will be called 'fakelb'.

whitespace damage

johannes

--=-OL0+UHPAPoGPd5SY+Ubc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKgC64AAoJEODzc/N7+Qmam6gP/A0gySK31z1qE/cMaqZvI1aR
zCT4OcHTKJiIdBeoxRTnmF8+zK7/0Irv02xLA/93IoLYJnEScuacC8ZbwZKJkJCQ
24vBK2d1DF3Aox/XAI9bvQ3g2snc7ZieoAHjDh2lwSuxaUA3CHFgV1oufrn5AktF
5Pdadsq/lsO1taVhFhSxQqFMWdVN7aBPIfYDEi5mOEn1YUh6fsJwYuzZMJzLqB/w
d8OGcA8/4HV/dksEN0g8x00IYcEFE6cfMtntheEeJlRD5kGrUb3TpeeJ1rxw0GKO
m/Jqeuom4JxeMCg0jJKv3JMkCsbIZFQM/1OBZZIKfw2t/TuH8RP5nXnC7NWjL4jg
bULl+eK8tTyC7rQkyItIuMD69RlYFnpp+Y+aIdsOWWdSB8t4RNczz7vD1HjP0Su4
YS5/BQrsNoJ6ibWqY4LKCa3kR2tgpoF7b69+HiBoGsUBoFzEh8jqJDKx2uJHJcG6
JMi5G9FwKdR1lUWptW9gtuRbRfsHrooZflncsoEOuGkMUZYoC6DtPne6fTY52hWU
xwcvvh6h7wkqDBS4fbt2IfD0Rzrh2ICyfqs8cqq2QmWOLieq8LAZ0ZpXbAFqkRJj
efuKuKfdXb7jyvTdld9DeIvPn38uj9bh0lwSvFqB7Q3iOxlxC3dbjHSHHA9kksPh
JwFr5Q8dieuoSxM++uM6
=X2EH
-----END PGP SIGNATURE-----

--=-OL0+UHPAPoGPd5SY+Ubc--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
