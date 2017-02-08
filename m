From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 8 Feb 2017 07:18:22 +0200
Message-ID: <20170208051822.GX6005@mtr-leonro.local>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207203649.GW6005@mtr-leonro.local>
 <1828884A29C6694DAF28B7E6B8A82373AB0E5B0B@ORSMSX109.amr.corp.intel.com>
 <20170207214303.GA76652@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="5KHo5BF8+9nsmMl/"
Cc: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Dalessandro, Dennis" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Weiny, Ira" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170207214303.GA76652-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--5KHo5BF8+9nsmMl/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 07, 2017 at 01:43:03PM -0800, Vishwanathapura, Niranjana wrote:
> On Tue, Feb 07, 2017 at 01:00:05PM -0800, Hefty, Sean wrote:
> > > I didn't read patches yet, and prefer to ask it in advance. Does this
> > > new ULP work with all
> > > drivers/infiniband/hw/* devices as it is expected from ULP?
> >
> > Like the way ipoib or srp work with all hw devices?  What is the real p=
oint of this question?
>
> Leon,
> It was already discussed in below threads.
>
> https://www.spinics.net/lists/linux-rdma/msg44128.html
> https://www.spinics.net/lists/linux-rdma/msg44131.html
> https://www.spinics.net/lists/linux-rdma/msg44155.html

Yes, but you still didn't answer on my question.
=46rom the first link:
------
  If that is your position then this should be a straight up IB ULP that
  works with any IB hardware.

Yes, see my comments in point #3 of my previous email...
------

Can I grab these patches and run on one of 14 drivers available in
drivers/inifiniband/hw/* ?

>
> Niranjana
>

--5KHo5BF8+9nsmMl/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliaqh0ACgkQ5GN7iDZy
WKdTexAAxS8f8kQae0el7C7LpPkNndYA043WgDSNQzxrFL6w4DVX4FWqRqNB3kSA
3D0uABT1sSx86TPAgg+njUUPMisCm0THvsriDMgLLuL5teagJsdHKZxjlIAp15M4
QU9GDX2XL71Z7B0+yAOlEVOLWMwZe8tObQr0Fc1jtzNlEcp1hNzFLMRV81Wmz6cM
uhY+TysMZzvu8lbw7laGsXLOAqpPsY/UQn7HQsXOz1WkpRsBGN4GUjJpx4lkZuma
yqVFr5EabHSmEr22iOiJ2W8T/gmDeOhtc6x9a9wdd43Y3FBBj4VGI+ZSPN+biCT+
RLVu0AQR4zXhsVln3wUQWsKN44ADUU1tR6EuBD805SLvSrqG3GaCXVwv2maiGzgn
gYEb0LsdkyJepUl6lj9sJyym+m1mL3DCPJbVx++E2Vl751/ryC13VeogGKnznEsB
+f5eQGT6SLtq1eJsLqKhMk7nItcDz5kzy3oQX5jUhb2fhyCIeNujkYdpauSAs6RM
odpqbNIPiH9b18ZNm78AkYlNIveD7LsNyR6ZlJgwYiueywB3N631MhSI35sEkkXK
DQCfRCZaHTaLABvHSOR2FE/kseWyeDzhwf1I0f7RAnte4s5Y2hfpZUVfnIv6IQ8Z
LozbfKpo3QJuKrqLZshEc2vrXT2FTXBcD9OrTdWtqg51EHdOYgQ=
=mH5X
-----END PGP SIGNATURE-----

--5KHo5BF8+9nsmMl/--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
