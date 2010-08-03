From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cleanup inclusion
Date: Mon, 02 Aug 2010 22:45:59 -0700 (PDT)
Message-ID: <20100802.224559.90801738.davem@davemloft.net>
References: <1280787101-5589-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755093Ab0HCFpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:45:40 -0400
In-Reply-To: <1280787101-5589-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue,  3 Aug 2010 06:11:41 +0800

> Commit ab95bfe01f9872459c8678572ccadbf646badad0 replaces bridge and macvlan
> hooks in __netif_receive_skb(), so dev.c doesn't need to include their headers.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
