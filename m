From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 1/6] smsc911x: add support for platform-specific irq flags
Date: Mon, 26 Jan 2009 08:45:56 +0000
Message-ID: <OFF11D92C1.37CFE5EA-ON8025754A.002FC604-8025754A.003046E9@smsc.com>
References: <20090125.174548.21690315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ian.saturley@smsc.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	stanley.miao@windriver.com, Sascha Hauer <s.hauer@pengutronix.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3525 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750778AbZAZIro (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 03:47:44 -0500
In-Reply-To: <20090125.174548.21690315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 26/01/2009 01:45:48:
> 
> These platform conversion patches still seem to be in a state
> of flux.
> 
> Steve could you resubmit this stuff and when doing so please clearly
> indicate exactly which ones you think I should stick into the net-2.6
> tree and which are to be added to the ARM tree.
> 
> Thanks.
> 

Thanks David,  I've also added two more minor initialisation workarounds
for hardware problems on in-tree boards.  The platform maintainers are
testing now.

I'll re-post the set when we're all happy, hopefully later this week.

Steve
