From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [IrDA] stir4200, switching to the kthread API
Date: Thu, 25 May 2006 16:20:39 -0700 (PDT)
Message-ID: <20060525.162039.35015343.davem@davemloft.net>
References: <20060525061944.GC24611@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	hch@lst.de, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19372
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S965181AbWEYXUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 19:20:34 -0400
To: samuel@sortiz.org
In-Reply-To: <20060525061944.GC24611@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Thu, 25 May 2006 06:19:44 +0000

> stir4200 uses a kernel thread for its TX/RX operations, and it is now
> converted to the kernel kthread API.
> Tested on an STIR4200 based dongle.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Enhancement, cleanup, and not a bug fix, so applied to net-2.6.18

Thanks.
