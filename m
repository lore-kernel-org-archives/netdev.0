From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: do not ignore route errors
Date: Fri, 25 Mar 2011 20:33:38 -0700 (PDT)
Message-ID: <20110325.203338.193726112.davem@davemloft.net>
References: <201103252345.p2PNjP1n025209@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752314Ab1CZDc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 23:32:59 -0400
In-Reply-To: <201103252345.p2PNjP1n025209@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 26 Mar 2011 01:45:25 +0200

> 	The "ipv4: Inline fib_semantic_match into check_leaf"
> change forgets to return the route errors. check_leaf should
> return the same results as fib_table_lookup.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Your mailer corrupted this patch, so I applied it by hand.
