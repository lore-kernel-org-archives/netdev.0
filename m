From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tg3: allow TSO on vlan devices
Date: Thu, 08 Jul 2010 23:12:45 -0700 (PDT)
Message-ID: <20100708.231245.70206684.davem@davemloft.net>
References: <1278605695.2651.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57008
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751411Ab0GIGMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:12:30 -0400
In-Reply-To: <1278605695.2651.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Jul 2010 18:14:55 +0200

> Similar to commit 72dccb01e8632aa (bnx2: Update vlan_features)
> 
> In order to enable TSO on vlan devices, tg3 needs to update
> dev->vlan_features.
> 
> Tested on HP NC326m (aka BCM5715S (rev a3))
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
