From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: route templates can be const
Date: Thu, 13 Sep 2012 16:53:17 -0400 (EDT)
Message-ID: <20120913.165317.1242475591849410473.davem@davemloft.net>
References: <1347436071.13103.695.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2IMUxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:53:18 -0400
In-Reply-To: <1347436071.13103.695.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 12 Sep 2012 09:47:51 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We kmemdup() templates, so they can be const.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
