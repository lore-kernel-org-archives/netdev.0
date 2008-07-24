From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference
 to `ei_close'
Date: Thu, 24 Jul 2008 12:25:48 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0807241224040.3283@shark.he.net>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
 <20080721191519.GA15843@elte.hu> <20080721214258.787a67ca@lxorguk.ukuu.org.uk>
 <20080722072334.GA25241@elte.hu> <48865899.3030209@garzik.org>
 <20080723104520.GA20672@elte.hu> <20080724052603.GA8744@elte.hu>
 <20080724100615.764bac36@lxorguk.ukuu.org.uk> <4888D631.8040401@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:38124 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752873AbYGXTZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 15:25:51 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 12:25:48 -0700
In-Reply-To: <4888D631.8040401@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008, Jeff Garzik wrote:

> Alan Cox wrote:
> > On Thu, 24 Jul 2008 07:26:03 +0200
> > Ingo Molnar <mingo@elte.hu> wrote:
> > 
> > > not sure it's known but despite all the fixes i still get:
> > 
> > I'll have a look at this next week or possibly the week after. The
> > original patches worked but they spent 3 months going round in circles
> > and I've completely given up even trying to work out what happened or why
> > all the previous updates I sent were ignored.
> 
> My apologies.  FWIW, from my point of view the same patch(es) kept getting
> fixed and updated and going around in circles, so I kept waiting.  Since it
> was was a net-next issue (until now), I lowered the priority and waited to let
> you guys (you, Andrew, Randy mainly) sort things out.

Randy got frustrated and gave up on this particular issue & patch(es).
This one has gone on far too long...

> So far the only remaining patch I have outstanding and needing to be applied
> is from Atsushi-san via Ingo (message id <20080723104520.GA20672@elte.hu>)...
> is that the last of it?

-- 
~Randy
