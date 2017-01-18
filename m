From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Wed, 18 Jan 2017 20:28:57 +0200
Message-ID: <20170118182857.GG32481@mtr-leonro.local>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="sxUMTo9WXJrtNoGr"
Cc: Ariel Almog <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10064.outbound.protection.outlook.com ([40.107.1.64]:40470
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751850AbdARVIz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 16:08:55 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--sxUMTo9WXJrtNoGr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jan 18, 2017 at 07:50:26PM +0200, Or Gerlitz wrote:
> On Wed, Jan 18, 2017 at 7:33 PM, Leon Romanovsky wrote:
> > On Wed, Jan 18, 2017 at 06:48:21PM +0200, Or Gerlitz wrote:
> >> On Wed, Jan 18, 2017 at 5:19 PM, Ariel Almog
> >> <arielalmogworkemails@gmail.com> wrote:
>
> >>> As of today, there is no single, simple, tool that allows monitoring
> >>> and configuration of RDMA stack.
>
> >> Before tool, what kernel UAPI you thought to use?
>
> > I'm aware of the following options:
> > 1) netlink
> > 2) RDMA ABI https://www.spinics.net/lists/linux-rdma/msg43960.html
> > 3) ioctl
> > 4) write/read
> >
> > The items 1 and 2 are preferred options and one of the main goals
> > for this RFC is to chose between them.
> >
> > For example, RDMA ABI has native support of querying and discovering
> > device capabilities via merge tree feature.
>
> To make it clear, when you wrote ABI in your initial email, I tend to
> think it was sort of unclear to the netdev crowd that you are talking
> on new UAPI which is now under the works for the IB subsystem, so with
> my netdev community member hat, I got confused... anyway

You are right, I missed it in my review for Ariel who wrote this RFC
and sent this RFC.

Thanks

--sxUMTo9WXJrtNoGr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh/s+kACgkQ5GN7iDZy
WKdR3A/7B36EKXRrPUYlAE6WDN8HbmhO5prXWvd/GJaCXarJMDi6jjm263v5hS1R
5WJpg1ZZYlmliaFZ32Pdq3EtWnORctfBiN0rv8FHczf/W5aYpF7L8WOGNERbN6Ev
3gRcznqBNwwOkDY+lk0I4VZU2hfdbcd1r3fZVcxv6vLVkh/H8zvZNzA5TJzrOOW1
Jyujv7j/6XZ9aKT/UqKqiB2n4fdzCXMrOePzebYQatFQ36iU7ZJSH/VfG/s8WDNz
LznmIYZDSDn6spF9nWqcrC2/QqK7WOvBvCnSua+4cC6rgbC5fLH6cEcihDITa6Ob
GoDELaF4ffngCm6pdkw+XKvEGKBGs2ZWYdG1IdBIsedA+qt6JSCy/K/LEl+A2ItE
c7yFnOpGUnULLjCJNaQxBIlCOtj5nS1uFe21VfAqwJRvJstLzyl8Oh1E5MRcL9Tl
fSg5vjT2FYicT0lqeTAqYBO+psCGRru5PWZ2UgCgFw5wD+V5ZKdMEnp4VZzbDmAm
sFaz2b5+yCuDJjVyEAm7sEwnMlpPwGsmBA/tn6+Lq3BbCz2MOGzMPSMfzl2n4WdD
mM/taKKE6kZKGTs9dfI2gw+2vZpRTCB8J77j9g55+vvTlhmR+dytUeOUkxsO2oZl
kMGPPL2n2vQgki7vf5UpkHtznF+XWvHzmmqGGrKE0BKDV7wwo2U=
=amsX
-----END PGP SIGNATURE-----

--sxUMTo9WXJrtNoGr--
