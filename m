From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Autoconfig link-local address on ip6-ip6 tunnel
 device
Date: Sat, 29 Nov 2003 20:47:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031129204701.37a06847.davem@redhat.com>
References: <Pine.LNX.4.58.0311051412180.28216@rhea.tcs.hut.fi>
	<20031125.035531.94714784.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.58.0311271147250.3257@rhea.tcs.hut.fi>
	<20031127.193910.96333709.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.58.0311281146560.9203@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0311281146560.9203@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Nov 2003 12:34:12 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> On Thu, 27 Nov 2003, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:
>=20
> > In article <Pine.LNX.4.58.0311271147250.3257@rhea.tcs.hut.fi> (at Thu=
, 27 Nov 2003 12:31:58 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi>=
 says:
> >
> > > here is a new version. I made some other minor changes to it too.
> >
> > looks fine.
> > --yoshfuji
>=20
> Hi Dave, Yoshifuji-san is now ok with this patch :) Would you apply it?

I thought some more about this and I am realizing this is not
a pure bug fix, I am very sure Linus will not take the change.

We can hold onto this until 2.6.1, ok?
