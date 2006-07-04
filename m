From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/5] Fix a warning in ioatdma
Date: Mon, 03 Jul 2006 19:28:32 -0700 (PDT)
Message-ID: <20060703.192832.112626788.davem@davemloft.net>
References: <200606300927.k5U9RN8m001468@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bboissin@gmail.com,
	benoit.boissinot@ens-lyon.org, christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54702
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751368AbWGDC2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:28:16 -0400
To: akpm@osdl.org
In-Reply-To: <200606300927.k5U9RN8m001468@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Fri, 30 Jun 2006 02:27:23 -0700

> From: "Benoit Boissinot" <bboissin@gmail.com>
> 
> drivers/dma/ioatdma.c: In function 'ioat_init_module':
> drivers/dma/ioatdma.c:830: warning: control reaches end of non-void function
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> Cc: "Chris Leech" <christopher.leech@intel.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks a lot.
