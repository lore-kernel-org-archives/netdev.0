From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: net/socket.c and net/compat.c
 cleanups
Date: Thu, 03 Jun 2010 20:05:29 -0700 (PDT)
Message-ID: <20100603.200529.183035231.davem@davemloft.net>
References: <1275575381.2456.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44932
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932161Ab0FDDFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:05:20 -0400
In-Reply-To: <1275575381.2456.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 16:29:41 +0200

> cleanup patch, to match modern coding style.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

It's modern, except for that trailing empty newline you added at
EOF of net/socket.c which GIT warns about and I had to fix.

Applied.
