From: David Miller <davem@davemloft.net>
Subject: Re: sock_getsockopt() not exported
Date: Thu, 18 Oct 2012 15:04:06 -0400 (EDT)
Message-ID: <20121018.150406.1266694498528564737.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7052@saturn3.aculab.com>
	<1350552612.26103.1281.camel@edumazet-glaptop>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7053@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393Ab2JRTEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:04:10 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7053@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 18 Oct 2012 13:03:55 +0100

> The problem is that it might be needed by an 'out of tree' driver.

We don't care.
