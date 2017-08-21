From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V3 net-next] net: hns3: Add support to change MTU in HNS3
 hardware
Date: Mon, 21 Aug 2017 17:47:41 +0300
Message-ID: <20170821144741.GN1724@mtr-leonro.local>
References: <20170821101223.111852-1-salil.mehta@huawei.com>
 <20170821142939.GG1703@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B875655@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="GEn4szYucjS2InE7"
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B875655-WFPaWmAhWqtUuCJht5byYAK1hpo4iccwjNknBlVQO8k@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--GEn4szYucjS2InE7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 21, 2017 at 02:32:40PM +0000, Salil Mehta wrote:
> Hi Andrew,
>
> > -----Original Message-----
> > From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
> > Sent: Monday, August 21, 2017 3:30 PM
> > To: Salil Mehta
> > Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Zhuangyuzeng (Yisen); lipeng (Y);
> > mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> > kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> > Subject: Re: [PATCH V3 net-next] net: hns3: Add support to change MTU
> > in HNS3 hardware
> >
> > On Mon, Aug 21, 2017 at 11:12:23AM +0100, Salil Mehta wrote:
> > > This patch adds the following support to the HNS3 driver:
> > > 1. Support to change the Maximum Transmission Unit of a
> > >    of a port in the HNS NIC hardware.
> > > 2. Initializes the supported MTU range for the netdevice.
> > >
> > > Signed-off-by: lipeng <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> > > Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >
> > Hi Salil
> >
> > Apart from Leon comments.
> >
> > Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
> >
> >     Andrew
>
> I will incorporate Leon's comment and float V4 patch today. Thanks!
>

Salil,

I had two comment there and not one. Please don't miss it :)

Thanks

> Best regards
> Salil
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--GEn4szYucjS2InE7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlma8o0ACgkQ5GN7iDZy
WKd2exAAmd+FXrAQQSdCrFd9AZskQOon7YZvOwOLbRAxQn7tyi0aDSEOeJ718Y46
QfqhtLfz6QUXifPztltpALPbEQitZBH0pAfNyBs6My5H6/XAy4Wi6h+/BsjXnyMZ
+EiEsI/GMVhkcnht1xEuk5GIVtmoDZgvVVZFr1zqB8Ub0IJbsnuDWy1OuBrLDOl0
NZLg7+BZ2chx5Z1KbASkevb69614UoTV2Thx34Y6c/HeGH0yb63uogmilkRBFmBl
sVvNcfwKxPLNP5zYLA7P5Qv83EvKSzhP4mcKRzr6/+QabhqdPvG2KQ5tR/3UDmcn
aXBIcp/e2Vc8ATRP4KRmF3H0QEHML6c346Md1kv0+Y8cpIlk+Zm8OlvFHsSCXSwC
kr/eTHJO3aZJryxj8hLBA1cTAXSJf+QsPrTQmZHumjjUWPNouayVFRD6YuBWEYU+
/fl0r7Gfh38eJ+ZGrOnBjnkq0K9P7emLuR6JToyqg3zN8awYOMzRyKV57sw5pT4X
6F2wSRsFT5lHsVbyRpwZeKSzyYiecAbVMvJJEELgDeOTe47uCYqzPEfP1DTrYyiq
GL7NCNjbrDJgLyXWy9eIi+stDc0bjzQcRGpB+RFb2NsbhocxvnysHj/VuW423JT1
Mnjft3h/PHiAKDTwOt323AHncJjuQNHS8/HBs+gTa1Efkm58HVQ=
=PvL8
-----END PGP SIGNATURE-----

--GEn4szYucjS2InE7--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
