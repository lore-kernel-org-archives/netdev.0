From: David Miller <davem@davemloft.net>
Subject: Re: [DECNET] ROUTE: fix rcu_dereference() uses in
 /proc/net/decnet_cache
Date: Thu, 10 Jan 2008 22:35:49 -0800 (PST)
Message-ID: <20080110.223549.148133401.davem@davemloft.net>
References: <20080109094637.GA28874@gondor.apana.org.au>
	<20080109113727.50eae500.dada1@cosmosbay.com>
	<20080110150610.c13e2125.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbYAKGfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:35:50 -0500
In-Reply-To: <20080110150610.c13e2125.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 10 Jan 2008 15:06:10 +0100

> [DECNET] ROUTE: fix rcu_dereference() uses in /proc/net/decnet_cache
 ...
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
