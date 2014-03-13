From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bcm63xx_enet: Stop pretending to support
 netpoll
Date: Thu, 13 Mar 2014 15:58:15 -0400 (EDT)
Message-ID: <20140313.155815.51286754935536745.davem@davemloft.net>
References: <87ppls774g.fsf_-_@xmission.com>
	<20140313.152616.852706173032905275.davem@davemloft.net>
	<CAGVrzcYFy5wr0fvdsLdo7G0GC-kmJ-tjR=sG70hFMJK5oYcr4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbaCMT6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:58:17 -0400
In-Reply-To: <CAGVrzcYFy5wr0fvdsLdo7G0GC-kmJ-tjR=sG70hFMJK5oYcr4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 13 Mar 2014 12:42:22 -0700

> There is no OF-aware platform using that driver. Part of the reason
> why it does not get much build coverage is the large header
> dependencies provided by arch/mips/include/asm/mach-bcm63xx. I will
> work on improving that.

Thanks in advance.
