From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2: Update vlan_features
Date: Thu, 23 Jul 2009 10:59:32 -0700 (PDT)
Message-ID: <20090723.105932.249439810.davem@davemloft.net>
References: <4A681029.4070600@voltaire.com>
	<4A681F63.7060001@gmail.com>
	<4A685122.3090300@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@voltaire.com, kaber@trash.net, fubar@us.ibm.com,
	netdev@vger.kernel.org, eilong@broadcom.com, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750976AbZGWR70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 13:59:26 -0400
In-Reply-To: <4A685122.3090300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Jul 2009 14:01:38 +0200

> [PATCH net-next-2.6] bnx2: Update vlan_features
> 
> In order to get full use of some advanced features of BNX2, we now need to
> fill dev->vlan_features.
> 
> Patch successfully tested with vlan devices built on top of bonding.
> (bond0 : one bnx2 slave, one tg3 slave (not yet vlan_features enabled)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Can I get some Broadcom ACKs for this?

Thanks.
