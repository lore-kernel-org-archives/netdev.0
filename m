From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/dev printk message priority
Date: Fri, 07 Jul 2006 16:54:20 -0700 (PDT)
Message-ID: <20060707.165420.94911105.davem@davemloft.net>
References: <20060707164104.32503b6d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:173
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751275AbWGGXxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 19:53:48 -0400
To: shemminger@osdl.org
In-Reply-To: <20060707164104.32503b6d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 7 Jul 2006 16:41:04 -0700

> The printk's in the network device interface code should all be tagged with
> severity.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
