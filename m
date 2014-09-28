From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] defxx: DEFEA fixes and updates
Date: Sun, 28 Sep 2014 17:22:43 -0400 (EDT)
Message-ID: <20140928.172243.604040716633227873.davem@davemloft.net>
References: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaI1VWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:22:45 -0400
In-Reply-To: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Thu, 25 Sep 2014 11:06:33 +0100 (BST)

>  I have finally got my hands on an EISA variation of the board (DEC 
> FDDIcontroller/EISA aka DEFEA) and was able to do some testing.  Here are 
> initial updates to the driver that address problems I encountered so far.  
> More to come later on as I get back to the system that I have in a remote 
> location -- I need to double-check MMIO support and see what might have 
> been causing spurious interrupts I saw with the 8259A PIC the board's 
> interrupt line has been routed to.

Series applied to net-next, thank you.
