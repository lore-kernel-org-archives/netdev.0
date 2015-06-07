From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove redundant checks II
Date: Sun, 07 Jun 2015 01:55:24 -0700 (PDT)
Message-ID: <20150607.015524.881752024890602181.davem@davemloft.net>
References: <1433400561.1895.34.camel@edumazet-glaptop2.roam.corp.google.com>
	<1433430072.1895.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbFGIz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 04:55:28 -0400
In-Reply-To: <1433430072.1895.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Jun 2015 08:01:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> For same reasons than in commit 12e25e1041d0 ("tcp: remove redundant
> checks"), we can remove redundant checks done for timewait sockets.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
