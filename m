From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: via: VIA_RHINE and VIA_VELOCITY should depend on
 HAS_DMA
Date: Sun, 28 Jun 2015 20:21:23 -0700 (PDT)
Message-ID: <20150628.202123.2157334131257205679.davem@davemloft.net>
References: <1435320502-4951-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: borneo.antonio@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbbF2DV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 23:21:26 -0400
In-Reply-To: <1435320502-4951-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 26 Jun 2015 14:08:22 +0200

> If NO_DMA=y:
 ...
> Before, the symbols depended implicitly on HAS_DMA through PCI or
> USE_OF.  Add explicit dependencies on HAS_DMA to fix this.
> 
> Fixes: commit b7d3282a245f4428 ("net: via/Kconfig: replace USE_OF with OF_???")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks Geert.
