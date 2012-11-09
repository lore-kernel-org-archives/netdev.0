From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netconsole: add oops_only module option
Date: Thu, 08 Nov 2012 22:07:33 -0500 (EST)
Message-ID: <20121108.220733.1522350577250113147.davem@davemloft.net>
References: <1352382158-3928-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756523Ab2KIDHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 22:07:37 -0500
In-Reply-To: <1352382158-3928-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu,  8 Nov 2012 21:42:38 +0800

> Some people wants to log only oops messages via netconsole,
> (this is also why netoops was invented)
> so add a module option for netconsole. This can be tuned
> via /sys/module/netconsole/parameters/oops_only at run time
> as well.
> 
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Seems reasonable, applied, thanks.
