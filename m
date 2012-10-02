From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,6/6] hyperv: Add buffer for extended info
 after the RNDIS response message.
Date: Tue, 02 Oct 2012 14:42:39 -0400 (EDT)
Message-ID: <20121002.144239.763143872910080563.davem@davemloft.net>
References: <1349191824-14001-1-git-send-email-haiyangz@microsoft.com>
	<1349191824-14001-6-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab2JBSml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:42:41 -0400
In-Reply-To: <1349191824-14001-6-git-send-email-haiyangz@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue,  2 Oct 2012 08:30:24 -0700

> In some response messages, there may be some extended info after the
> message.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
