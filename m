From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net-next: remove useless union keyword
Date: Mon, 17 May 2010 17:48:01 -0700 (PDT)
Message-ID: <20100517.174801.68118614.davem@davemloft.net>
References: <1274071108-5142-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53793
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755823Ab0ERArw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:47:52 -0400
In-Reply-To: <1274071108-5142-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon, 17 May 2010 12:38:28 +0800

> remove useless union keyword in rtable, rt6_info and dn_route.
> 
> Since there is only one member in a union, the union keyword isn't useful.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thank you.
