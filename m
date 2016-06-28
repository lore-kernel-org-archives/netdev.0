From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: diag: Add support to filter on device
 index
Date: Tue, 28 Jun 2016 05:25:31 -0400 (EDT)
Message-ID: <20160628.052531.715609559856475342.davem@davemloft.net>
References: <1466732571-31133-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbcF1J0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 05:26:01 -0400
In-Reply-To: <1466732571-31133-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 23 Jun 2016 18:42:51 -0700

> Add support to inet_diag facility to filter sockets based on device
> index. If an interface index is in the filter only sockets bound
> to that index (sk_bound_dev_if) are returned.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
