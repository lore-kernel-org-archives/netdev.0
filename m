From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/802/tr.c: remove an unused export
Date: Tue, 16 May 2006 15:23:49 -0700 (PDT)
Message-ID: <20060516.152349.72783731.davem@davemloft.net>
References: <20060516184843.GP10077@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63911
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932220AbWEPWYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 18:24:54 -0400
To: bunk@stusta.de
In-Reply-To: <20060516184843.GP10077@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 16 May 2006 20:48:43 +0200

> This patch removes the unused EXPORT_SYMBOL(tr_source_route).
> 
> (No, the usage in net/llc/llc_output.c can't be modular.)
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks.
