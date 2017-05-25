From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: ax88796: support generating a
 random mac address
Date: Thu, 25 May 2017 17:01:58 -0400 (EDT)
Message-ID: <20170525.170158.2209987008603285994.davem@davemloft.net>
References: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
        <20170525205741.yoyiszdgchqcnqp2@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933798AbdEYVCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 17:02:01 -0400
In-Reply-To: <20170525205741.yoyiszdgchqcnqp2@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
Date: Thu, 25 May 2017 22:57:41 +0200

> Hello David,
> 
> On Thu, May 25, 2017 at 10:55:11PM +0200, Uwe Kleine-König wrote:
>> Instead of falling back to 00:00:00:00:00:00 generate a random address
>> if none is provided via platform data or from the the device's register
> 
> s/the the/the/
> 
> should I resend for this, or can you fixup at commit time (assuming this
> patch is ok).

I can fix that up.
