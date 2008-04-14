From: Matthew Dharm <mdharm-usb-JGfshJpz5UybPZpvUQj5UqxOck334EZe@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Mon, 14 Apr 2008 14:59:05 -0700
Message-ID: <20080414215905.GD16272@one-eyed-alien.net>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5gxpn/Q6ypwruk0T"
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080414213238.GB28833-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--5gxpn/Q6ypwruk0T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I will be the first to admit that I'm picking a nit here, but...

On Mon, Apr 14, 2008 at 02:32:39PM -0700, Greg KH wrote:
> Subject: USB: add option hso driver

> +config USB_HSO
> +	tristate "Option USB High Speed Mobile Devices"

> + * Driver for Option High Speed Mobile Devices.

> +#define MOD_DESCRIPTION			"USB High Speed Option driver"

Would it be possible to pick one of "High Speed Option" and "Option...
High Speed" and then be consistent with the acronym of "hso" or "ohs"?  Or
maybe call it "option_hs" or something even more clear?

Mixing them just makes it more difficult for people to use grep and google.

Matt

--=20
Matthew Dharm                              Home: mdharm-usb@one-eyed-alien.=
net=20
Maintainer, Linux USB Mass Storage Driver

DP: And judging from the scores, Stef has the sma... =20
T:  LET'S NOT GO THERE!
					-- Dust Puppy and Tanya
User Friendly, 12/11/1997

--5gxpn/Q6ypwruk0T
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIA9OpHL9iwnUZqnkRArpLAJ9kR1p6BPIj3e8Pw+RW4y4CVRwL3wCgseAC
RZQjuOgeRDUNjJ4CslysqMs=
=ujLq
-----END PGP SIGNATURE-----

--5gxpn/Q6ypwruk0T--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
