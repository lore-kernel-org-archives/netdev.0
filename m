From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: use skb_dst_copy() in
 ip_copy_metadata()
Date: Mon, 05 Jul 2010 19:08:48 -0700 (PDT)
Message-ID: <20100705.190848.191383067.davem@davemloft.net>
References: <1278064102.2530.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53021
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757562Ab0GFCIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:08:34 -0400
In-Reply-To: <1278064102.2530.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Jul 2010 11:48:22 +0200

> Avoid touching dst refcount in ip_fragment().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
