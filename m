From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sgi-xp: fix a use after free
Date: Sun, 19 Jun 2011 20:19:09 -0700 (PDT)
Message-ID: <20110619.201909.400328791027636798.davem@davemloft.net>
References: <1308523956.3539.105.camel@edumazet-laptop>
	<20110620024455.GF3525@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: holt@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab1FTDTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 23:19:18 -0400
In-Reply-To: <20110620024455.GF3525@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robin Holt <holt@sgi.com>
Date: Sun, 19 Jun 2011 21:44:56 -0500

> Thank you Eric.
> 
> David, if you want me to submit this through Andrew Morton, I can do
> that instead.

I applied it to my net-2.6 tree long before you replied.
