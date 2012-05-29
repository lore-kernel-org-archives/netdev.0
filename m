From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: allow full size 8021Q frames to be received
Date: Tue, 29 May 2012 17:22:56 -0400 (EDT)
Message-ID: <20120529.172256.2047259231925942792.davem@davemloft.net>
References: <1338280301.4120.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	trond@chromium.org, grundler@chromium.org, pstew@chromium.org,
	allan@asix.com.tw
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877Ab2E2VXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 17:23:13 -0400
In-Reply-To: <1338280301.4120.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 May 2012 10:31:41 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> asix driver drops 8021Q full size frames because it doesn't take into
> account VLAN header size.
> 
> Tested on AX88772 adapter.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
