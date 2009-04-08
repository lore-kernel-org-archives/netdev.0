From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: don't reset the rx coal timer on
 interface up
Date: Wed, 08 Apr 2009 15:43:00 -0700 (PDT)
Message-ID: <20090408.154300.40282323.davem@davemloft.net>
References: <20090408204414.GC4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754439AbZDHWnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:43:17 -0400
In-Reply-To: <20090408204414.GC4738@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Wed, 8 Apr 2009 22:44:14 +0200

> Move SDMA configuration from interface up to port probe, to prevent
> overwriting the receive coalescing timer value on interface up.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied, thanks Lennert.
