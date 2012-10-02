From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/6] hyperv: Fix the max_xfer_size in RNDIS
 initialization
Date: Tue, 02 Oct 2012 14:40:07 -0400 (EDT)
Message-ID: <20121002.144007.686391086427399732.davem@davemloft.net>
References: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab2JBSkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:40:23 -0400
In-Reply-To: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue,  2 Oct 2012 08:30:19 -0700

> According to RNDIS specs, Windows sets this size to
> 0x4000. I use the same value here.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
