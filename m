From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC]: Fix IPv6 AH calculation in outbound
Date: Fri, 25 May 2007 00:10:57 -0700 (PDT)
Message-ID: <20070525.001057.39157422.davem@davemloft.net>
References: <20070525160914.49b54c9d.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44953
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750981AbXEYHKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 03:10:54 -0400
In-Reply-To: <20070525160914.49b54c9d.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 25 May 2007 16:09:14 +0900

> Hello David,
> 
> I send a patch to fix IPv6 AH calculation of outbound.
> This is for the linux-2.6.22-rc2.

Thank you for resending I will apply this.

> BTW, I sent a patch to fix kernel panic when using
> inter address family IPsec on loopback.
> Could you let me know the status?

I have it in my mailbox, I will look into it, thanks
for reminding me.
