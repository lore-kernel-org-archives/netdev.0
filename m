From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/2] tcp: add generic netlink support for
 tcp_metrics
Date: Thu, 30 Aug 2012 12:20:14 -0400 (EDT)
Message-ID: <20120830.122014.1866418915648598899.davem@davemloft.net>
References: <1345734105-28328-1-git-send-email-ja@ssi.bg>
	<1345734105-28328-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913Ab2H3QUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:20:19 -0400
In-Reply-To: <1345734105-28328-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 23 Aug 2012 18:01:44 +0300

> 	Add support for genl "tcp_metrics". No locking
> is changed, only that now we can unlink and delete
> entries after grace period. We implement get/del for
> single entry and dump to support show/flush filtering
> in user space.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I like it.

Please address Eric Dumazet's feedback and resubmit, thanks!
