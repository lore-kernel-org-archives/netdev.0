From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] qed: Fix maximum number of CQs for iWARP
Date: Wed, 20 Sep 2017 16:50:32 +0300
Message-ID: <20170920135032.GP5788@mtr-leonro.local>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
 <1505841979-26365-4-git-send-email-Michal.Kalderon@cavium.com>
 <20170919174610.GK5788@mtr-leonro.local>
 <CY1PR0701MB2012B07A2FCD08D598CCFEDB88610@CY1PR0701MB2012.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="jnYfR+Q8IWTs8BNa"
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CY1PR0701MB2012B07A2FCD08D598CCFEDB88610-UpKza+2NMNLHMJvQ0dyT705OhdzP3rhOnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--jnYfR+Q8IWTs8BNa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 20, 2017 at 05:46:35AM +0000, Kalderon, Michal wrote:
> From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Sent: Tuesday, September 19, 2017 8:46 PM
> On Tue, Sep 19, 2017 at 08:26:18PM +0300, Michal Kalderon wrote:
> >> The maximum number of CQs supported is bound to the number
> >> of connections supported, which differs between RoCE and iWARP.
> >>
> >> This fixes a crash that occurred in iWARP when running 1000 sessions
> >> using perftest.
> >>
> >> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> >> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> >> ---
> >
> >It is worth to add Fixes line.
> >
> >Thanks
> The original code was there before we had iWARP support, so this doesn't
> exactly fix an older commit, but fixes iWARP code in general.

So add Fixes which points to iWARP ennoblement patch.

Thanks

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--jnYfR+Q8IWTs8BNa
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnCcigACgkQ5GN7iDZy
WKcfKg/9EOrgokvt0HYDcdSSMfqcbwbVhZ9QbcxnE9QD9/lhQGwEicuA8hHhOi65
aEpzS6rvDykt6cuViQfgu3ZkuaC7bWRBS7nZ5cndN/bcumkLLc3ZHt6PsCak724U
huGXE3ci/ykHAptPDnnU/iFtOZAus10CJAhF2ydigfYPupbKpNEBbN3rxTo/aRRb
nyS+UUplJgRUfoqDL6SkFDc6rMqVGLOV5bYSDnal7kiDv5QJ94pmCLl1M1Q/i+Nf
jtT4hi75zCe91FGw5UCbm/5oOqeBahOvlneOLcEhukNRRB8hUz6E8c8bzgfLXJrr
jh0PvBfiFsVkPKZ+HFypEp/cMmtdVScEZU3yG/tBGheid2mm8QseSp1ZuCP5NV1+
BEt1VoNRhXHZ+uDYj9BIsr8Bm/bjnz7B1uThr/kg1VuXegCQe/EygGULqRDxEGuo
TfBzSbfhccpFSyA+nTy1g1Iq8Sn4NBFG2QwyWy79PhWYp36CnU3ToO68uenFvyvU
9wTZWsKYU01luSfdZe2vHRosEqc7TG5Ws9WL9x3GcCkqN2yUNIXAllfkfmeWt9+n
AXb1rHIH421qP2VwKvG2TR3m7mXeiwDRAVatj+28f2sOCiTRgw4UjK0zedKFX1Ao
YZbj548cm7DaocSAHni2aIKnRo1ERR90SmTIDHGgVYttDchLdH4=
=/F4x
-----END PGP SIGNATURE-----

--jnYfR+Q8IWTs8BNa--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
