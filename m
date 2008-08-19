From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: Remove unneeded in-kernel API functions
Date: Tue, 19 Aug 2008 13:17:03 -0700 (PDT)
Message-ID: <20080819.131703.181831524.davem@davemloft.net>
References: <20080813145526.10579.84270.stgit@flek.lan>
	<200808191310.36061.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ramirose@gmail.com, casey@schaufler-ca.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57716
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757841AbYHSURE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 16:17:04 -0400
In-Reply-To: <200808191310.36061.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 19 Aug 2008 13:10:35 -0400

> I didn't see this get pulled into your latest 2.6.27 push but I think 
> it's a good candidate for 2.6.27, it's dead code removal.  If you 
> disagree, no problem, just let me know so I can throw it on my patchset 
> for 2.6.28.

Linus seems to think I'm already merging too much stuff:

	http://marc.info/?l=linux-kernel&m=121916548518920&w=2

So yeah, I think this cleanup can wait for 2.6.28
