From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,2/6] hyperv: Fix the missing return value in
 rndis_filter_set_packet_filter()
Date: Tue, 02 Oct 2012 14:42:05 -0400 (EDT)
Message-ID: <20121002.144205.475981870169341463.davem@davemloft.net>
References: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
	<1349191824-14001-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806Ab2JBSmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:42:07 -0400
In-Reply-To: <1349191824-14001-2-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue,  2 Oct 2012 08:30:20 -0700

> Return ETIMEDOUT when the reply message is not received in time.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
