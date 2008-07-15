From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Mon, 14 Jul 2008 23:58:02 -0700 (PDT)
Message-ID: <20080714.235802.243338298.davem@davemloft.net>
References: <E1KIMIg-0007MB-00@gondolin.me.apana.org.au>
	<20080714.045806.213105998.davem@davemloft.net>
	<487C487C.5030403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753890AbYGOG6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 02:58:01 -0400
In-Reply-To: <487C487C.5030403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 15 Jul 2008 08:49:32 +0200

> For example, hash_dst() in net/netfilter/xt_hashlimit.c is using the
> following code :

Aha, now I see what you mean.

Thanks, I'll take this into consideration.
