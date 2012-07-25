From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/2] hyperv: Add a check for ring_size value
Date: Wed, 25 Jul 2012 15:48:58 -0700 (PDT)
Message-ID: <20120725.154858.2001228990733826265.davem@davemloft.net>
References: <1343239722-21328-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879Ab2GYWs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:48:59 -0400
In-Reply-To: <1343239722-21328-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Wed, 25 Jul 2012 11:08:41 -0700

> It prevents ring_size being set to a too small value.
> 
> Reported-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
