From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Tue, 22 Aug 2017 18:50:38 +0200
Message-ID: <20170822165038.afmpeztr2yzffhbq@flea.lan>
References: <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red>
 <20170819203836.GA21567@lunn.ch>
 <20170820065757.GA6081@Red>
 <20170820142545.GB24150@lunn.ch>
 <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch>
 <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
 <20170821142321.GE1703@lunn.ch>
 <CAGb2v64E4T=1ff3POGuXZA=MvjGAnKQ6OF6A3sT_cU-=jh6zNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fcnm4qn4b73qe32y"
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v64E4T=1ff3POGuXZA=MvjGAnKQ6OF6A3sT_cU-=jh6zNw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--fcnm4qn4b73qe32y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 22, 2017 at 11:39:22PM +0800, Chen-Yu Tsai wrote:
> Now can we please decide on something? We're a week and a half from
> the 4.13 release. If mdio-mux is wrong, then we could have two mdio
> nodes (internal-mdio & external-mdio).

I can only emphasize this. I'm afraid that if we don't have an
agreement and a patch implementing it with the proper acks by the end
of the week, we'll have to revert all the DT bits and the bindings.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--fcnm4qn4b73qe32y
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZnGDdAAoJEBx+YmzsjxAg5yEP/2m2H7eRbVEXvOyl+7+Il1pz
LFP10ogmPgfMwk9mWDaF/7hxRJgbSBhWsbo1uFyxx0VSQ8w2P4XEBuXpN/LMLchK
DxzmgKVtqAy6PW1KJiY/HG1zVPQf8RpwnGO2fynQX3EWZkLuAf7RhyCVBUfk2qKR
YMX6Shnl6UV1krb/9WhTAKwwv90D1puqiiBShgA3TRStoc1CcagD3vQv7ykNckd1
oYw6X689F3MTrr6qQ+vvqmZgKLbVDdNGfeiSBnU88aDXYdaZGB/SrfydXC4yMFQD
XVmEd2yGhKCLqWxfG6Jr0bRe950VXvJy95yG/ZBR+HDdZbit4ISMHjQOsxAN3nMo
t7JBr2ttzAyDrtCq1OuL2yb6Jn/XBj99wd6bd+AK0hhWV9b7dXTZ8GN6UihYdMy+
2/P7QZU4CNmcKMCSduskntbDzAtsmKJYd2zvRH6ZEyeGIWOn9eCUslDGrBLIV4A9
kAKnKEP70dn4ulHLPZw55XIbg7uBu75e3zPvNGR+jYoBJYeL/SyQ/Dy43pZpELzy
Hf0bwDZ6/Iqmj3UCholejx+yTgWr6tKz3Ws4HaMTLnSLvBQ+H1F6cpIPGgyC84PO
QIziy2qEeZQXJ30It0Wpfsq/KWaxJ5alq1uTWa9vALMeDlFe0Xf5FgCh9C5epaOB
wL7YQRB7GZj4XONEmU0q
=XIqj
-----END PGP SIGNATURE-----

--fcnm4qn4b73qe32y--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
