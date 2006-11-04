From: David Miller <davem@davemloft.net>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 17:02:54 -0800 (PST)
Message-ID: <20061103.170254.104035374.davem@davemloft.net>
References: <454BD5FD.2030502@pobox.com>
	<20061103.160230.71088561.davem@davemloft.net>
	<454BE209.4020407@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41932
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932550AbWKDBDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 20:03:19 -0500
To: jgarzik@pobox.com
In-Reply-To: <454BE209.4020407@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 03 Nov 2006 19:42:49 -0500

> David Miller wrote:
> > I guess you can argue that, like IP addresses, this WoL thing is an
> > attribute of the "system".
> 
> Yeah, it's definitely a system state.  When the magic packet arrives, 
> the WOL wire on the motherboard is tickled, turning the machine on.

Ok, and Stephen seems to agree now too on this point.

I think there is merit to Stephen's assertion that WoL should
be off by default.  It allows remote entities to do something
to your computer.

I'm happy to hear counter-arguments, of course :-)
