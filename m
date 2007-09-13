From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] sgiseeq: replace use of dma_cache_wback_inv
Date: Wed, 12 Sep 2007 23:54:16 -0400
Message-ID: <46E8B468.4000109@garzik.org>
References: <20070904134101.GA20191@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37229 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763404AbXIMDyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 23:54:20 -0400
In-Reply-To: <20070904134101.GA20191@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> The sgiseeq driver is one of the few remaining users of the ancient
> cache banging DMA API.  Replaced with the modern days DMA API.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


