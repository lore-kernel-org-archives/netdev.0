From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Annotates neigh_invalidate()
Date: Wed, 10 Mar 2010 07:35:03 -0800 (PST)
Message-ID: <20100310.073503.115804633.davem@davemloft.net>
References: <1268199654.2872.134.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53867
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756760Ab0CJPen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:34:43 -0500
In-Reply-To: <1268199654.2872.134.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Mar 2010 06:40:54 +0100

> Annotates neigh_invalidate() with __releases() and __acquires() for
> sparse sake.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
