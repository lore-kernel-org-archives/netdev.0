From: Andi Kleen <ak@suse.de>
Subject: Re: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 21:53:15 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020415215315.A16910@wotan.suse.de>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE86A@nyc285ex01.nyc.corp.yr.com> <Pine.LNX.4.44.0204152232230.1201-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Milam, Chad" <Chad_Milam@nyc.yr.com>, netdev@oss.sgi.com,
   "Julian Anastasov <ja@ssi.bg>" <IMCEANOTES-Julian+20Anastasov+20+3Cja+40ssi+2Ebg+3E@avee-health.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0204152232230.1201-100000@u.domain.uli>
List-Id: netdev.vger.kernel.org

> 	I mean when you see the dst cache overflow message can the
> command help? But ... may be are running a kernel patched with your
> changes. I'm asking this because I know cases where wrong changes
> can make problems with dst cache. But the plain kernel should be
> fine. One question more: can you say that this box is used only as
> router or what kind of TCP or UDP connections you have (to/from the
> box)? There can be some corner cases in the dst cache usage from
> connected sockets.

I would suspect CheckPoint (I think it has kernel modules, hasn't it)
We had a similar report of such a thing a few months ago and they were
using CheckPoint too.

-Andi
