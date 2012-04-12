From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ixp4xx_eth: Fix up the get_ts_info ethtool
 method.
Date: Thu, 12 Apr 2012 16:01:37 -0400 (EDT)
Message-ID: <20120412.160137.225142227575597672.davem@davemloft.net>
References: <1333814170-30940-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754230Ab2DLUBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 16:01:39 -0400
In-Reply-To: <1333814170-30940-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat,  7 Apr 2012 17:56:10 +0200

> Commit e77bd1ec121ee4163a6b42a44e87b2e382c39e04 added support for a
> new ethtool function, but that cannot compile due to a misnamed global
> variable. Not that it really matters (since the IXP4xx does compile
> either, as of about Linux 3.1) but just in case, this patch fixes the
> misnamed variable in the PHC driver.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied, thanks Richard.
