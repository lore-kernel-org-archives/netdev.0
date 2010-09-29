From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sit: enable lockless xmits
Date: Wed, 29 Sep 2010 13:27:24 -0700 (PDT)
Message-ID: <20100929.132724.232763661.davem@davemloft.net>
References: <1285678421.3154.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755303Ab0I2U1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 16:27:04 -0400
In-Reply-To: <1285678421.3154.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Sep 2010 14:53:41 +0200

> SIT tunnels can benefit from lockless xmits, using NETIF_F_LLTX
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
