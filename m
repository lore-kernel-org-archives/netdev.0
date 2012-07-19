From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix again the time difference calculation
Date: Thu, 19 Jul 2012 13:01:30 -0700 (PDT)
Message-ID: <20120719.130130.1429102248074335993.davem@davemloft.net>
References: <1342728165-2046-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab2GSUBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 16:01:33 -0400
In-Reply-To: <1342728165-2046-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 19 Jul 2012 23:02:45 +0300

> 	Fix again the diff value in rt_bind_exception
> after collision of two latest patches, my original commit
> actually fixed the same problem.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I noticed this too while respinning the routing cache deletion
patches, I'll apply this, thanks.
