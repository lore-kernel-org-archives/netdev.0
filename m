From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Mon, 09 Dec 2013 21:09:16 -0500 (EST)
Message-ID: <20131209.210916.1684103670392129860.davem@davemloft.net>
References: <52A66C0D.4050409@windriver.com>
	<20131209.202321.2134510956668375662.davem@davemloft.net>
	<52A6763C.4050101@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab3LJCJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:09:18 -0500
In-Reply-To: <52A6763C.4050101@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 10 Dec 2013 10:02:36 +0800

> Can I just reply to custom "Yes, wrong checksum value and
> non-decrypted packet
> is not big deal when your peer host receiving them"?

It's a packet spamming tool, take that into consideration.

Regardless of what you may think, it is simply the case that you can't
just remove something because you perceive it as not useful to anyone.

This goes doubly for something exposed to users for a decade.

Please change your patch series to retain the feature.

Thanks.
