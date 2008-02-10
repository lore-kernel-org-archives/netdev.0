From: David Miller <davem@davemloft.net>
Subject: Re: [patch 7/7] pppol2tp: fix printk warnings
Date: Sat, 09 Feb 2008 23:18:04 -0800 (PST)
Message-ID: <20080209.231804.12709241.davem@davemloft.net>
References: <200802081120.m18BK9QQ021642@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43491
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755824AbYBJHRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:17:33 -0500
In-Reply-To: <200802081120.m18BK9QQ021642@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 08 Feb 2008 03:11:17 -0800

> From: Andrew Morton <akpm@linux-foundation.org>
 ...
> Not all platforms implement u64 with unsigned long long.  eg: powerpc.
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
