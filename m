From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: fix panic on load
Date: Sun, 31 Oct 2010 09:34:02 -0700 (PDT)
Message-ID: <20101031.093402.193722333.davem@davemloft.net>
References: <1288539978.2660.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cooldavid@cooldavid.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756176Ab0JaQdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 12:33:39 -0400
In-Reply-To: <1288539978.2660.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 31 Oct 2010 16:46:18 +0100

> Its now illegal to call netif_stop_queue() before register_netdev()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
