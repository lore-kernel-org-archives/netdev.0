From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 17:14:52 -0400 (EDT)
Message-ID: <20110524.171452.2301523213150184145.davem@davemloft.net>
References: <20110524203714.GG28521@hmsreliant.think-freely.org>
	<4DDC1A4E.6080700@gmail.com>
	<12577.1306271574@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.2p.debian@gmail.com, nhorman@tuxdriver.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757167Ab1EXVQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 17:16:04 -0400
In-Reply-To: <12577.1306271574@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 24 May 2011 14:12:54 -0700

> 	How much harder is it to fix the locking and permit the action
> in question here?

I've reverted and am holding off on this patch until this discussion
is resolved.
