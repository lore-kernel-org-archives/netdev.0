From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: davinci_cpdma: export
 cpdma_chan_get_stats
Date: Thu, 22 Aug 2013 20:49:16 -0700 (PDT)
Message-ID: <20130822.204916.803953122543635320.davem@davemloft.net>
References: <1377172020-28053-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3HWDtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 23:49:23 -0400
In-Reply-To: <1377172020-28053-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Thu, 22 Aug 2013 13:47:00 +0200

> This is needed when the cpsw driver is built as module.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Only in net-next, because in 'net' the function (while it does exist)
is not referenced by anything.

So I have applied this patch to net-next.
