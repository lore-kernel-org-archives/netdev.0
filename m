From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v2 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 20 Sep 2016 19:23:06 +0300
Message-ID: <20160920162306.GP26673@leon.nu>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <20160920121151.GK26673@leon.nu>
 <CY1PR0701MB133773B2CB71FA6362CADCFF90F70@CY1PR0701MB1337.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ssZxAlvqSOvXAj81"
Cc: "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Borundia, Rajesh" <Rajesh.Borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CY1PR0701MB133773B2CB71FA6362CADCFF90F70-UpKza+2NMNLi6bjPjkn3FE5OhdzP3rhOnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--ssZxAlvqSOvXAj81
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 20, 2016 at 01:33:25PM +0000, Elior, Ariel wrote:
> > On Tue, Sep 20, 2016 at 01:35:52PM +0300, Ram Amrani wrote:
> ...
> > > The series adds on top of RFC v1:
> > > * a check for all drivers that IB_ACCESS_MW_BIND isn't set for ib_get_dma_mr
> > > * relocation of qedr user API to include/rdma/uapi/providers/
> > > * removal of qedr_devlist_local
> > > * fixed error handling in qedr_alloc_resources()
> > > * configuration of PBL in ib_map_mr_sg() driver implementation,
> > >   rather than post_send's IB_WR_REG_MR
> > > * misc.: placed code in proper patch, fixed a few comments,
> > >   removed extra parentheses
> > >
> > > Thanks for everyone which pointed out problems in the driver.
> > >
> > > Any review/comment is appreciated.
> >
> > Very nice,
> > Any reason why didn't you drop debug module parameter and decided to
> > mimic already available kernel core functionality?
> >
> > You got technical explanations why it is bad idea to use it. If you need additional
> > voices
> > to support my claims, you will find them in thread about VERBOSE flag and responses
> > from
> > Doug, and Dennis.
> >
> > Thanks
> Hi Leon,
> The RFC cover letter lists what has been addressed. Debug printouts are not addressed in V2 as the discussion on that topic is not concluded (more thoughts from us on debug printouts incoming on the thread). There were many comments to V1 which are not relevant to debug printouts which are addressed by V2. We are requesting further comment, hence RFC V2. Rest assured, if it is the final opinion in the relevant discussion that pr_debug is the way to go, that's what we'll do.

The module parameters is no-go.

> Thanks,
> Ariel

--ssZxAlvqSOvXAj81
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4WJqAAoJEORje4g2clinrYQP/2C1Dvqnvy9stcXYuHaz/XzZ
pqi5d3Tijv7byl0M+9dt5Aw6Oz9Khu4tIcZkPgdIIrlacmZX8lZk4LmYD0oX+sdn
dIo5SG4YOpviq5hCDTpTJWcEnhSziFPln5DJ5siZeg/Mj8J6luD1wBg3AC4+JoT2
77Mo+WB0M2oXbSDCHQHulj3MfNDyoVA4aja7+K6S7jwuLp6fODtQrMXLPq6mzHtY
4/D8S79UolA46B2LNYx2BmeysuA/Emb4UgZNsfAiu79+0vRHkJiRPs8iUgBTM1zm
MkzhhiJdlUyZAtyL3LXBUslApsQJyyNsGPwqS38mcuy0SK7iDGw9IgPsf+gCjnxO
kcc1oxkGbJuJIfVZ0Smpo/Sn7kjohyeinFe9EoB+OJzhNuRw5scFN+9wT9VGgrUl
06G6eRjnRyjfWf/puCbFEHhi/nGK6DVMyfOsRRpQHY9yjgAZ/+uinJm2TwQu4eoa
8x9Y3hPAGEH/AdODo782bkoo/AhQbeMIddGTVfqrAHqEaIAe4mTELPe4+b+ogGV/
l/+rE2X7woAlUo9W2ZvmkvebA/VKv3SYHoaQJDYNMdycs5y4ca0aaiB99+EsStxG
wjBZvaY9RpCP9Wte8UpscrH2RrSD+a4WoPnnFaAkIquopzW3mVxXmXA4clXYus5v
UUUaeUS2vlj7XflOrA9k
=QGOX
-----END PGP SIGNATURE-----

--ssZxAlvqSOvXAj81--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
