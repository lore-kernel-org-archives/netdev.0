From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Fix VF register on bonding devices
Date: Mon, 25 Jul 2016 11:19:37 -0700 (PDT)
Message-ID: <20160725.111937.1134118351940061313.davem@davemloft.net>
References: <1469236490-27704-1-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	vkuznets@redhat.com, driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbcGYSTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 14:19:38 -0400
In-Reply-To: <1469236490-27704-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Fri, 22 Jul 2016 18:14:50 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> Added a condition to avoid bonding devices with same MAC registering
> as VF.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
