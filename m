From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ieee802154: merge cleanup
Date: Mon, 30 Nov 2009 21:55:01 -0800 (PST)
Message-ID: <20091130.215501.267396660.davem@davemloft.net>
References: <20091130.010520.56312368.davem@davemloft.net>
	<4B149498.4030307@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34785
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751917AbZLAFyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 00:54:55 -0500
In-Reply-To: <4B149498.4030307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Dec 2009 04:59:20 +0100

> A small cleanup after last net-2.6 merge into net-next-2.6
> 
> As we are going to free skb, no need to set skb->skb_iif or skb->dev
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

-ECORRUPTEDPATCH

Are you really sure you want to keep using Thunderbird for
your email? :-)
