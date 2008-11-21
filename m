From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [PATCH] asix.c: Fix AX88178 connectivity with 10/100
 networks
Date: Thu, 20 Nov 2008 20:41:16 -0800 (PST)
Message-ID: <20081120.204116.176717841.davem@davemloft.net>
References: <1227194741.4420.37.camel@dhollis-lnx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pktoss@gmail.com
To: dhollis@davehollis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34120
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752672AbYKUElR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:41:17 -0500
In-Reply-To: <1227194741.4420.37.camel@dhollis-lnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Hollis <dhollis@davehollis.com>
Date: Thu, 20 Nov 2008 10:25:41 -0500

> Add AX_MEDIUM_ENCK also when speed = 10/100Mbps.  This makes the Belkin
> F5D5055 device work properly.
> 
> Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
> Acked-by: David Hollis <dhollis@davehollis.com>

I already applied Pantelis's patch and it's in Linus's tree.
