From: David Miller <davem@davemloft.net>
Subject: Re: [patch 01/28] fore200e_param_bs_queue() must be __devinit
Date: Fri, 10 Aug 2007 15:13:13 -0700 (PDT)
Message-ID: <20070810.151313.88474339.davem@davemloft.net>
References: <200708102111.l7ALBm47009367@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38841
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762685AbXHJWNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:13:23 -0400
In-Reply-To: <200708102111.l7ALBm47009367@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:11:48 -0700

> From: Adrian Bunk <bunk@stusta.de>
> 
> WARNING: drivers/built-in.o(.text+0x6203bb): Section mismatch: reference to .init.text:fore200e_param_bs_queue (between 'fore200e_initialize' and 'fore200e_monitor_putc')
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Bug fix, so applied to net-2.6, thanks.
