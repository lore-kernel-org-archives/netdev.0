From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/11] net/wanrouter/wanmain.c: cleanups
Date: Mon, 05 Feb 2007 18:07:48 -0800 (PST)
Message-ID: <20070205.180748.82375731.davem@davemloft.net>
References: <200702060032.l160W8LR004633@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965417AbXBFCHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:07:49 -0500
In-Reply-To: <200702060032.l160W8LR004633@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:31:05 -0800

> From: Adrian Bunk <bunk@stusta.de>
> 
> This patch contains the following cleanups:
> - make the following needlessly global functions static:
>   - lock_adapter_irq()
>   - unlock_adapter_irq()
> - #if 0 the following unused global functions:
>   - wanrouter_encapsulate()
>   - wanrouter_type_trans()
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
