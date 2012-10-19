From: David Miller <davem@davemloft.net>
Subject: Re: sock_getsockopt() not exported
Date: Fri, 19 Oct 2012 13:12:56 -0400 (EDT)
Message-ID: <20121019.131256.2026785630531870853.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7053@saturn3.aculab.com>
	<1350563275.26103.1465.camel@edumazet-glaptop>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7056@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab2JSRNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 13:13:00 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7056@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Fri, 19 Oct 2012 10:26:52 +0100

> The Linux interface is all done with wrapper functions
> that get compiled on the target system so we can ship
> a big binary 'blob'.

Your maintainence problem, not our's.
