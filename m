From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET]: Clean up netlink NLM_F_ECHO and rtnl event
 notifications
Date: Wed, 09 Aug 2006 21:16:13 -0700 (PDT)
Message-ID: <20060809.211613.42776476.davem@davemloft.net>
References: <20060809204821.216122988@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46982
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161015AbWHJEQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 00:16:06 -0400
To: tgraf@suug.ch
In-Reply-To: <20060809204821.216122988@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 09 Aug 2006 22:48:21 +0200

> Aims at cleaning up rtnetlink event notifications and implements
> real NLM_F_ECHO support.
> 
> Please disregard my last IPv4 routing related patchset, I'll
> resubmit it based on this patchset.

All applied, nice work Thomas.

Especially nice to see the RTNL semaphore export go away :-)

Thanks.
