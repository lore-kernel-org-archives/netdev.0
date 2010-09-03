From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: add special mode forwarding=2 to send RS while
 configured as router
Date: Fri, 03 Sep 2010 09:43:34 -0700 (PDT)
Message-ID: <20100903.094334.91333726.davem@davemloft.net>
References: <20100903130420.GB28460@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44229
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755973Ab0ICQnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 12:43:17 -0400
In-Reply-To: <20100903130420.GB28460@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Fri, 3 Sep 2010 09:04:20 -0400

> Similar to accepting router advertisement, the IPv6 stack does not send router
> solicitations if forwarding is enabled.
> 
> This patch enables this behavior to be overruled by setting forwarding to the
> special value 2.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Applied.
