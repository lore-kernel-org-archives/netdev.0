From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Implement batching in send buffer
Date: Sun, 29 Mar 2015 12:50:10 -0700 (PDT)
Message-ID: <20150329.125010.1277802432650323277.davem@davemloft.net>
References: <1427385817-17811-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbbC2Tl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:41:28 -0400
In-Reply-To: <1427385817-17811-1-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu, 26 Mar 2015 09:03:37 -0700

> With this patch, we can send out multiple RNDIS data packets in one send buffer
> slot and one VMBus message. It reduces the overhead associated with VMBus messages.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
