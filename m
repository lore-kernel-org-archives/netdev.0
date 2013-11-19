From: David Miller <davem@davemloft.net>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Tue, 19 Nov 2013 16:13:13 -0500 (EST)
Message-ID: <20131119.161313.743887333007019981.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com>
	<528A9A36.50903@pobox.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlord@pobox.com, eric.dumazet@gmail.com, ming.lei@canonical.com,
	netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab3KSVNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 16:13:15 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 19 Nov 2013 10:04:11 -0000

> There is a patch to xhci-ring.c that should fix the SG problem.
> http://www.spinics.net/lists/linux-usb/msg97176.html
> 
> I think it should apply to the 3.12 sources.

David, please get this into Linus's tree and queued up for -stable
as soon as possible, thank you.
