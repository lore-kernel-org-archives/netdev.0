From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]ipv6:When we droped a package,we should return
 NET_RX_DROP instead of 0
Date: Fri, 29 Aug 2008 14:07:01 -0700 (PDT)
Message-ID: <20080829.140701.204972161.davem@davemloft.net>
References: <48B7A7E1.70307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40426
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750855AbYH2VHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 17:07:06 -0400
In-Reply-To: <48B7A7E1.70307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Fri, 29 Aug 2008 15:40:17 +0800

> When we droped a package,we should return NET_RX_DROP instead of 0
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

Applied, thank you.
