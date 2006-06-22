From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix net-core kernel-doc
Date: Thu, 22 Jun 2006 16:00:35 -0700 (PDT)
Message-ID: <20060622.160035.51841776.davem@davemloft.net>
References: <20060622151443.24dd8d9e.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22506
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161377AbWFVXAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 19:00:52 -0400
To: rdunlap@xenotime.net
In-Reply-To: <20060622151443.24dd8d9e.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Thu, 22 Jun 2006 15:14:43 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Warning(/var/linsrc/linux-2617-g4//include/linux/skbuff.h:304): No description found for parameter 'dma_cookie'
> Warning(/var/linsrc/linux-2617-g4//include/net/sock.h:1274): No description found for parameter 'copied_early'
> Warning(/var/linsrc/linux-2617-g4//net/core/dev.c:3309): No description found for parameter 'chan'
> Warning(/var/linsrc/linux-2617-g4//net/core/dev.c:3309): No description found for parameter 'event'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks a lot Randy.
