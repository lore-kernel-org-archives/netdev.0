From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: validate HWTSTAMP ioctl parameters
Date: Wed, 19 Oct 2011 17:01:13 -0400 (EDT)
Message-ID: <20111019.170113.726671711637418475.davem@davemloft.net>
References: <20110926.160443.1205173553442138535.davem@davemloft.net>
	<cover.1318584677.git.richard.cochran@omicron.at>
	<eca6d279cd96da44d9ad26bdda8fc8c2130c03c1.1318584677.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab1JSVBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 17:01:16 -0400
In-Reply-To: <eca6d279cd96da44d9ad26bdda8fc8c2130c03c1.1318584677.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 14 Oct 2011 11:37:48 +0200

> This patch adds a sanity check on the values provided by user space for
> the hardware time stamping configuration. If the values lie outside of
> the absolute limits, then the ioctl request will be denied.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Thanks a lot for following up on this.

Applied, thanks again Richard.
