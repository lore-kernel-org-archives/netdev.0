From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/5] genirq: Add IRQ affinity notifiers
Date: Mon, 07 Feb 2011 20:44:48 +0000
Message-ID: <1297111488.4077.16.camel@bwh-desktop>
References: <alpine.LFD.2.00.1101192214350.3211@localhost6.localdomain6>
	 <20110119.132730.57462002.davem@davemloft.net>
	 <alpine.LFD.2.00.1101192229500.3211@localhost6.localdomain6>
	 <20110119.134812.123988295.davem@davemloft.net>
	 <alpine.LFD.2.00.1101221735080.31804@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, therbert@google.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25020 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab1BGUow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 15:44:52 -0500
In-Reply-To: <alpine.LFD.2.00.1101221735080.31804@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-01-22 at 17:38 +0100, Thomas Gleixner wrote:
> B1;2401;0cOn Wed, 19 Jan 2011, David Miller wrote:
> > You said you had stuff before Ben's patches, and that's why you needed
> > to provide me with an -rc1 relative version of his commits.
> 
> I hope a rc2 relative version works as well :)
>  
> > If that's not the case, then yes it would work just fine.
> > 
> > Just give me the URL to pull from, thanks!
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git irq/numa
> 
> @Ben: Your patch was pretty white space damaged. Please be more
> careful next time.

Oh, I see that struct irq_affinity_notify members were indented with
spaces; is that what you mean?  Sorry, I've no idea how that happened.

Anyway, thanks for applying this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

