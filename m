From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sctp: ipv6: avoid touching device refcount
Date: Thu, 05 Nov 2009 21:08:21 -0800 (PST)
Message-ID: <20091105.210821.268389761.davem@davemloft.net>
References: <4AF1ECBA.6070301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753645AbZKFFH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:56 -0500
In-Reply-To: <4AF1ECBA.6070301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 22:06:02 +0100

> Avoid touching device refcount in sctp/ipv6, thanks to RCU
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
