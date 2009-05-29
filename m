From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] atm: unset IFF_XMIT_DST_RELEASE in
 clip_setup()
Date: Fri, 29 May 2009 01:47:17 -0700 (PDT)
Message-ID: <20090529.014717.43205025.davem@davemloft.net>
References: <4A1EFEC9.3050905@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757976AbZE2IrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:47:17 -0400
In-Reply-To: <4A1EFEC9.3050905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 May 2009 23:14:49 +0200

> clip_start_xmit() needs skb->dst so tell dev_hard_start_xmit()
> to no release it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
