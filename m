From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/7] bnx2x section fix
Date: Sat, 09 Feb 2008 23:16:49 -0800 (PST)
Message-ID: <20080209.231649.196670814.davem@davemloft.net>
References: <200802081120.m18BK73F021629@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, sam@ravnborg.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757497AbYBJHRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:17:00 -0500
In-Reply-To: <200802081120.m18BK73F021629@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 08 Feb 2008 03:11:15 -0800

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> gcc-3.4.4 on powerpc:
> 
> drivers/net/bnx2x.c:73: error: version causes a section type conflict
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
