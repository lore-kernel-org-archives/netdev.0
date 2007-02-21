From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Wed, 21 Feb 2007 17:03:04 +0900 (JST)
Message-ID: <20070221.170304.65080002.yoshfuji@linux-ipv6.org>
References: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
	<20070220.231545.104035801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aramoto@linux-ipv6.org,
	kozakai@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	nhorman@tuxdriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:56890 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbXBUIC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 03:02:56 -0500
In-Reply-To: <20070220.231545.104035801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070220.231545.104035801.davem@davemloft.net> (at Tue, 20 Feb 2007 23:15:45 -0800 (PST)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Thu, 15 Feb 2007 02:35:14 +0900 (JST)
> 
> > Please consider pulling the following changesets available on the
> > 	2.6.20-net-2.6-20070214-FOR_DAVEM
> > branch at
> > 	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
> > (on top of commit 928ba4169dc1d82c83105831f5ddb5472379b440).
> 
> Unfortunately, the merge window is closed so I really cannot merge all
> of this, only bug fixes at this point.
> 
> If you would like to avoid this, please be more prompt in merging to
> me next time the merge window opens up.

Sorry about that.

The ipv4-in-ipv6 functionality depends on the cross-protocol ipsec
framework, which was not ready earlier, so I hesitated.

Anyway, I'll cook up 2 trees; one for fix and another for 2.6.22.

I'll send a note when the "fix" tree has become ready.

And, I will queue the Optimistic DAD patch as well other changes into
my "dev" tree.

Regards,

--yoshfuji
