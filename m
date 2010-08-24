From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: ip_append_data() optim
Date: Tue, 24 Aug 2010 14:45:18 -0700 (PDT)
Message-ID: <20100824.144518.48521816.davem@davemloft.net>
References: <1282685687.2467.175.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50757
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755435Ab0HXVpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:45:00 -0400
In-Reply-To: <1282685687.2467.175.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Aug 2010 23:34:47 +0200

> Compiler is not smart enough to avoid a conditional branch.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
