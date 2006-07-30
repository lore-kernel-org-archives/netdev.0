From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include/linux/netfilter_bridge.h: header cleanup
Date: Sun, 30 Jul 2006 15:45:21 -0700 (PDT)
Message-ID: <20060730.154521.35507382.davem@davemloft.net>
References: <20060729074545.GA6843@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50053
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751429AbWG3WpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:45:10 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060729074545.GA6843@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 29 Jul 2006 11:45:45 +0400

> Header doesn't use anything from atomic.h.
> It fixes headers_check warning:
> 
> include/linux/netfilter_bridge.h requires asm/atomic.h, which does not exist
> 
> Compile tested on
> alpha     arm   i386-up  sparc    sparc64-up  x86_64
> alpha-up  i386           sparc64  sparc-up    x86_64-up
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
