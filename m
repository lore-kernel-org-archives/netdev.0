From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Fri, 16 Jan 2004 00:01:17 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.000117.133662773.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.58.0401141726490.24125@rhea.tcs.hut.fi>
	<20040115.223430.100570163.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.58.0401151537000.29722@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.58.0401151537000.29722@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.58.0401151537000.29722@rhea.tcs.hut.fi> (at Thu, 1=
5 Jan 2004 16:53:42 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> sa=
ys:

> On Thu, 15 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:
>=20
> > In article <Pine.LNX.4.58.0401141726490.24125@rhea.tcs.hut.fi> (at Th=
u, 15 Jan 2004 15:00:24 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi=
> says:
> >
> > > On Wed, 14 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=
=B1=D1=CC=C0 wrote:
> > >
> > > > I don't think so. Proxy should not depend on netfilter.
> > :
> > > There aren't that many ways of doing this "hack" cleanly.
> >
> > Well...
> >
> > We (or only me?) might have mis-understood the "proxy" in Linux :-P
> > It is not for proxy in rfc2461, is it?
> > It is for proxy in Thaler's draft, isn't it?
>=20
> No, it's for the proxy go old proxy in rfc2461 :(

Really? I doubt that because of usage and comment in net/ipv4.

--yoshfuji
