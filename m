From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 24 Jul 2004 08:16:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090671399.1160.0.camel@jzny.localdomain>
References: <1090612669.1218.47.camel@jzny.localdomain>
	 <20040723135945.7f50b02c.davem@redhat.com>
	 <1090630154.1134.6.camel@jzny.localdomain>
	 <20040723.214240.76745170.yoshfuji@linux-ipv6.org>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
        arekm@pld-linux.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040723.214240.76745170.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-23 at 21:42, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> In article <1090630154.1134.6.camel@jzny.localdomain> (at 23 Jul 2004 2=
0:49:15 -0400), Jamal Hadi Salim <hadi@znyx.com> says:
>=20
> > I will take care of it next week when i get back.=20
> > If 2.6.8 is coming out before end of next week, i would suggest undoi=
ng
> > Stephens patch.
>=20
> I've talked about this with Jamal.
>=20
> I believe it is very important to maintain th original (or=20
> traditional) ABI, which has been used in -2.6.7(?).
>=20
> So, I'd rather say, let's remove (or disable) whole thing=20
> until we find the way to avoid breaking ABIs.

Just back out Stephens patch for now until i get back.

cheers,
jamal
