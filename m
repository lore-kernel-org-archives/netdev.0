From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Thu, 03 May 2012 08:24:19 -0700
Message-ID: <1336058659.27487.80.camel@wwguy-huron>
References: <1336017985.12425.9.camel@edumazet-glaptop>
	 <4FA21087.1080801@gmail.com> <1336022373.12425.24.camel@edumazet-glaptop>
	 <20120503.012502.44731688706812861.davem@davemloft.net>
	 <20120503151418.GJ9285@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	alexander.duyck@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9338 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757170Ab2ECPav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 11:30:51 -0400
In-Reply-To: <20120503151418.GJ9285@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On Thu, 2012-05-03 at 11:14 -0400, John W. Linville wrote:
> On Thu, May 03, 2012 at 01:25:02AM -0400, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 03 May 2012 07:19:33 +0200
> > 
> > > My last patch against iwlwifi is still waiting to make its way into
> > > official tree.
> > > 
> > > http://www.spinics.net/lists/netdev/msg192629.html
> > 
> > John, please rectify this situation.
> > 
> > The Intel Wireless folks said they would test it, but that was more
> > than a month ago.
> > 
> > It's not acceptable to let bug fixes rot for that long, I don't care
> > what their special internal testing procedure is.
> > 
> > If they give you further pushback, please just ignore them and apply
> > Eric's fix directly.
> > 
> > Thank you.
> 
> I imagine that this somehow got lost in the shuffle during the
> merge window.  That doesn't excuse it, of course.
> 
> It has waited long enough already, so I'll just go ahead and take it.
> 
it is my mistake to lost this patch during the iwlwifi re-factor work,
the patch is no longer apply and I ask Eric to rebase the patch.

Sorry again for the mistake

Thanks
Wey
