From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/5] drivers/dma/iovlock.c: make num_pages_spanned()
 static
Date: Mon, 03 Jul 2006 19:27:31 -0700 (PDT)
Message-ID: <20060703.192731.78705547.davem@davemloft.net>
References: <200606300927.k5U9RMob001465@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52910
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751354AbWGDC1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:27:15 -0400
To: akpm@osdl.org
In-Reply-To: <200606300927.k5U9RMob001465@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Fri, 30 Jun 2006 02:27:22 -0700

> From: Adrian Bunk <bunk@stusta.de>
> 
> This patch makes the needlessly global num_pages_spanned() static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks Adrian.
