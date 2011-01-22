From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH net-next-2.6 1/5] genirq: Add IRQ affinity notifiers
Date: Sat, 22 Jan 2011 17:38:24 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1101221735080.31804@localhost6.localdomain6>
References: <alpine.LFD.2.00.1101192214350.3211@localhost6.localdomain6> <20110119.132730.57462002.davem@davemloft.net> <alpine.LFD.2.00.1101192229500.3211@localhost6.localdomain6> <20110119.134812.123988295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:45601 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935Ab1AVQii (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 11:38:38 -0500
In-Reply-To: <20110119.134812.123988295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

B1;2401;0cOn Wed, 19 Jan 2011, David Miller wrote:
> You said you had stuff before Ben's patches, and that's why you needed
> to provide me with an -rc1 relative version of his commits.

I hope a rc2 relative version works as well :)
 
> If that's not the case, then yes it would work just fine.
> 
> Just give me the URL to pull from, thanks!

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git irq/numa

@Ben: Your patch was pretty white space damaged. Please be more
careful next time.

Thanks,

	tglx

