From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Sun, 12 Sep 2010 19:28:20 +0200
Message-ID: <201009121928.20238.rjw@sisk.pl>
References: <1283672983.3402.38.camel@edumazet-laptop> <201009082221.16356.rjw@sisk.pl> <4C8C7957.7080207@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C8C7957.7080207-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday, September 12, 2010, Plamen Petrov wrote:
> =D0=9D=D0=B0 08.9.2010 =D0=B3. 23:21, Rafael J. Wysocki =D0=BD=D0=B0=D0=
=BF=D0=B8=D1=81=D0=B0:
> > On Wednesday, September 08, 2010, David Miller wrote:
> >> From: Jarek Poplawski<jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Date: Wed, 8 Sep 2010 06:20:04 +0000
> >>
> >>> We need both of them. I hope David could add this too:
> >>>
> >>> Tested-by: Plamen Petrov<pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
> >>
> >> Done, and applied, thanks :-)
> >
> > Please kindly let me know when Linus gets them, so that I can close=
 the bug.
> >
> > Rafael
>=20
> Now that both commits that fix my problems are in Linus' tree, the
> bug can be closed, but these fixes should go in 2.6.35.y, too.
> So, CCing -stable.

Thanks, bug closed.

Rafael
