From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/2] sctp: fix a typo in prototype of
 __sctp_rcv_lookup()
Date: Wed, 03 Oct 2012 16:28:47 -0400 (EDT)
Message-ID: <20121003.162847.312544751568068374.davem@davemloft.net>
References: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594Ab2JCU2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 16:28:51 -0400
In-Reply-To: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed,  3 Oct 2012 17:43:21 +0200

> Just to avoid confusion when people only reads this prototype.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I think we should apply this one, regardless of what happens
to patch #2 in this series.
