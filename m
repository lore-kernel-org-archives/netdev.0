From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sky2: add support for receive hashing (v3)
Date: Sat, 24 Apr 2010 20:04:26 -0700 (PDT)
Message-ID: <20100424.200426.71125197.davem@davemloft.net>
References: <20100422234319.149785036@vyatta.com>
	<4BD0F8AA.2060700@garzik.org>
	<20100424162239.1aae32e0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750961Ab0DYDEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 23:04:20 -0400
In-Reply-To: <20100424162239.1aae32e0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 24 Apr 2010 16:22:39 -0700

> Subject: sky2: add support for receive hashing
> 
> Sky2 hardware supports hardware receive hash calculation.
> Now that Receive Packet Steering is available, add support
> to enable it.
> 
> This version does not depend on CONFIG_RPS. Also set_flags rejects
> all values except RXHASH, so driver won't have to change next time
> somebody adds a new one.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
