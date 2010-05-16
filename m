From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-next: remove useless union keyword
Date: Sun, 16 May 2010 00:53:02 -0700 (PDT)
Message-ID: <20100516.005302.223474568.davem@davemloft.net>
References: <1273223662-6804-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752914Ab0EPHwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 03:52:53 -0400
In-Reply-To: <1273223662-6804-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri,  7 May 2010 17:14:22 +0800

> remove useless union keyword in rtable, rt6_info and dn_route.
> 
> Since there is only one member in a union, the union keyword isn't useful.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Sorry, this patch no longer applies cleanly to net-next-2.6

Please respin and resubmit this patch.

Thank you.
