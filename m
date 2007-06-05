From: David Miller <davem@davemloft.net>
Subject: Re: [stable] "[IPV6]: Fix routing round-robin locking." breaks
 manual default route (bug 8349)
Date: Tue, 05 Jun 2007 16:43:17 -0700 (PDT)
Message-ID: <20070605.164317.78711072.davem@davemloft.net>
References: <465B45E0.3040007@simon.arlott.org.uk>
	<20070605233616.GF3723@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	berni@birkenwald.de, stable@kernel.org, linkfanel@yahoo.fr
To: chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758791AbXFEXnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 19:43:03 -0400
In-Reply-To: <20070605233616.GF3723@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Tue, 5 Jun 2007 16:36:16 -0700

> Rather than reverting that patch, applying this patch should fix
> your ipv6 issue:
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff_plain;h=7ebba6d14f8d63cad583bf1cc0330b601d5a8171
> 
> I'll wait for Dave or Yoshifuji to decide if this is a proper -stable
> patch.

I have a batch of stuff to send to -stable tonight and I
will make sure that this will be part of it.

Thanks for reminding me.
