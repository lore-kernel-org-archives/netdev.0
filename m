From: David Miller <davem@davemloft.net>
Subject: Re: Invalid sk_policy[] access
Date: Tue, 23 Feb 2016 15:20:45 -0500 (EST)
Message-ID: <20160223.152045.440181358695767083.davem@davemloft.net>
References: <20160222010201.GB23053@oracle.com>
	<20160223121244.GI28756@oracle.com>
	<alpine.LRH.2.20.1602232132190.30129@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, sparclinux@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755195AbcBWUXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 15:23:55 -0500
In-Reply-To: <alpine.LRH.2.20.1602232132190.30129@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Tue, 23 Feb 2016 21:36:24 +0200 (EET)

> Sorry, I do not understand - what is 32-bit on V440? The kernel should 
> be 64-bit since it's sun4u.

Indeed, the kernel is 64-bit in both cases.

And the userland bit-arity has no relevance whatsoever for this bug.
