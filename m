From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: fix broken driver
Date: Thu, 19 Sep 2013 13:56:28 -0400 (EDT)
Message-ID: <20130919.135628.1201613770803318193.davem@davemloft.net>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab3ISR4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 13:56:30 -0400
In-Reply-To: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 19 Sep 2013 12:33:30 -0400 (EDT)

> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Cc: stable@kernel.org # 3.11

First, this is missing the reported-by and tested-by tags provided
by people who tested this patch.

Secondly, CC:'ing stable is not the correct way to submit networking
patches for -stable inclusion.  You simply ask me to queue them up
for -stable explicitly instead.

Please re-submit this with the currect signoffs, thank you.
