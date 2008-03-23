From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Sun, 23 Mar 2008 03:29:49 -0700 (PDT)
Message-ID: <20080323.032949.194309002.davem@davemloft.net>
References: <47BDC848.50607@cosmosbay.com>
	<20080226.182120.183405235.davem@davemloft.net>
	<47C92F49.4070100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754809AbYCWK3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 06:29:34 -0400
In-Reply-To: <47C92F49.4070100@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 01 Mar 2008 11:26:17 +0100

> [PATCH] loopback: calls netif_receive_skb() instead of netif_rx()

Eric, did you get a chance to kernel stack usage stress this
thing out like I asked?

Thanks.
