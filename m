From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Staging: batman-adv: Remove batman-adv from staging
Date: Thu, 16 Dec 2010 14:31:36 -0800 (PST)
Message-ID: <20101216.143136.258102148.davem@davemloft.net>
References: <20101216.140153.232733922.davem@davemloft.net>
	<1292538497-13604-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38461
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751031Ab0LPWbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:31:08 -0500
In-Reply-To: <1292538497-13604-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Thu, 16 Dec 2010 23:28:17 +0100

> batman-adv is now moved to net/batman-adv/ and can be removed from
> staging.
> 
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Cc: David S. Miller <davem@davemloft.net>

As discussed in a previous email, please submit this to Greg KH for
the staging tree, not to me for net-next-2.6.

Otherwise there will be all kinds of unnecessary merge conflicts.
