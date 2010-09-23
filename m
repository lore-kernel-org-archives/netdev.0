From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: return operator cleanup
Date: Thu, 23 Sep 2010 14:34:41 -0700 (PDT)
Message-ID: <20100923.143441.235699425.davem@davemloft.net>
References: <1285224237.2380.111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754348Ab0IWVeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:34:22 -0400
In-Reply-To: <1285224237.2380.111.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Sep 2010 08:43:57 +0200

> Change "return (EXPR);" to "return EXPR;"
> 
> return is not a function, parentheses are not required.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
