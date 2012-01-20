From: David Miller <davem@davemloft.net>
Subject: Re: Recent RCU changes in the networking code
Date: Fri, 20 Jan 2012 13:48:57 -0500 (EST)
Message-ID: <20120120.134857.1063822988966503185.davem@davemloft.net>
References: <CAO+b5-oqBNyXy+-a712VrnhSteVSPk8J5Om95E-ZQHtJBVgJAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bvanassche@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab2ATStC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 13:49:02 -0500
In-Reply-To: <CAO+b5-oqBNyXy+-a712VrnhSteVSPk8J5Om95E-ZQHtJBVgJAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart Van Assche <bvanassche@acm.org>
Date: Fri, 20 Jan 2012 17:35:54 +0000

> As far as I can see commit cf778b00e96df6d64f8e21b8395d1f8a859ecdc7 is
> a fix for commit a9b3cd7f323b2e57593e7215362a7b02fc933e3a, the latter
> has been included in 3.2 but the former has not yet been sent to
> stable@vger.kernel.org. Shouldn't commit cf778b0 be sent to stable
> such that it gets included in the v3.2.x series ?

Sure.
