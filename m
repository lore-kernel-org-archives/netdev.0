From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/5] IOAT: fix sparse ulong warning
Date: Mon, 03 Jul 2006 19:25:21 -0700 (PDT)
Message-ID: <20060703.192521.71087847.davem@davemloft.net>
References: <200606300927.k5U9RK0P001458@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net,
	christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50350
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751051AbWGDCZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:25:06 -0400
To: akpm@osdl.org
In-Reply-To: <200606300927.k5U9RK0P001458@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Fri, 30 Jun 2006 02:27:20 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix sparse warning:
> drivers/dma/ioatdma.c:444:32: warning: constant 0xFFFFFFFFFFFFFFC0 is so big it is unsigned long
> 
> Also needs a MAINTAINERS entry.
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> Cc: Chris Leech <christopher.leech@intel.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks Randy.
