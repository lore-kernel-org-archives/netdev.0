From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: fix typo for initial_quantum
Date: Tue, 08 Oct 2013 16:52:50 -0400 (EDT)
Message-ID: <20131008.165250.1455903432621627430.davem@davemloft.net>
References: <1381175418.12191.19.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756737Ab3JHUww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:52:52 -0400
In-Reply-To: <1381175418.12191.19.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Oct 2013 12:50:18 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCA_FQ_INITIAL_QUANTUM should set q->initial_quantum
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
