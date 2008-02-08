From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/3] [IUCV] fixes for net-2.6.25
Date: Thu, 07 Feb 2008 18:07:54 -0800 (PST)
Message-ID: <20080207.180754.122971648.davem@davemloft.net>
References: <20080207142842.852003000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: braunu@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752437AbYBHCHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 21:07:23 -0500
In-Reply-To: <20080207142842.852003000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>
Date: Thu, 07 Feb 2008 15:28:42 +0100

> -- 
> Dave,
> 
> the following 3 patches are intended for 2.6.25 and contain:
> - locking changes in iucv.c
> - locking changes in af_iucv.c
> - extra checkings for successful allocations in af_iucv.c
> - secure handling of send_skb_q list in af_iucv.c

Applied, thanks.
