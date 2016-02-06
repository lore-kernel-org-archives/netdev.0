From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: fastopen: accept data/FIN present in
 SYNACK
Date: Sat, 06 Feb 2016 03:13:02 -0500 (EST)
Message-ID: <20160206.031302.1262914455786911151.davem@davemloft.net>
References: <1454389388-1506-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sara@sinodun.com, ycheng@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbcBFINI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:13:08 -0500
In-Reply-To: <1454389388-1506-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon,  1 Feb 2016 21:03:06 -0800

> Implements RFC 7413 (TCP Fast Open) 4.2.2, accepting payload and/or FIN
> in SYNACK messages, and prepare removal of SYN flag in tcp_recvmsg()

Series applied, thanks Eric.
