From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6/addrconf: Fix minor addrlabel thinko
Date: Wed, 09 Sep 2009 03:42:36 -0700 (PDT)
Message-ID: <20090909.034236.204237186.davem@davemloft.net>
References: <4AA5F3D3.80706@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: tgohad@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51859
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750934AbZIIKmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 06:42:19 -0400
In-Reply-To: <4AA5F3D3.80706@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Gohad <tgohad@mvista.com>
Date: Mon, 07 Sep 2009 23:04:03 -0700

> 
> Fix apparent thinko related to RTM_DELADDRLABEL, introduced by commit 2a8cc6c89039e0530a3335954253b76ed0f9339a.
> 
> 
> Signed-off-by: Tushar Gohad <tgohad@mvista.com>

Looks good to me, applied to net-next-2.6, thanks.
