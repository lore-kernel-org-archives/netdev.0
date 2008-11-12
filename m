From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ib_net pointer should depends on CONFIG_NET_NS
Date: Wed, 12 Nov 2008 00:54:27 -0800 (PST)
Message-ID: <20081112.005427.148258596.davem@davemloft.net>
References: <20081111111946.GD3665@x200.localdomain>
	<20081111.164554.143409564.davem@davemloft.net>
	<491A75E1.8010704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751368AbYKLIy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 03:54:28 -0500
In-Reply-To: <491A75E1.8010704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 12 Nov 2008 07:21:21 +0100

> We can shrink size of "struct inet_bind_bucket" by 50%, using read_pnet() and write_pnet()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied!
