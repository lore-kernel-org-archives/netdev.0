From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: refactor tcp splice receive path to improve
 readability
Date: Sat, 05 Jul 2008 23:43:40 -0700 (PDT)
Message-ID: <20080705.234340.53048543.davem@davemloft.net>
References: <200806241303.36453.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751544AbYGFGnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 02:43:41 -0400
In-Reply-To: <200806241303.36453.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 24 Jun 2008 13:03:36 +0300

> Please consider applying this to net-next-2.6. I've minimally tested it and no 
> performance or functional problems were found. It applies on top of the 
> previous fix I've sent ([PATH] tcp: fix for splice receive when used with 
> software LRO). 

It doesn't apply cleanly even though I've merged in net-2.6
which includes your splice receive bug fix.

Please respin this patch, thanks.
