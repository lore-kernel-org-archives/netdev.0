From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] netns: dont alloc ipv6 fib timer list
Date: Tue, 22 Jul 2008 14:33:52 -0700 (PDT)
Message-ID: <20080722.143352.10502246.davem@davemloft.net>
References: <20080722212927.937523165@vyatta.com>
	<20080722212951.551812845@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56349
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753517AbYGVVdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:33:52 -0400
In-Reply-To: <20080722212951.551812845@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 22 Jul 2008 14:29:28 -0700

> FIB timer list is a trivial size structure, avoid indirection and just
> put it in existing ns.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
