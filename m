From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net 2/2] sfc: Use 64-bit writes for TX push where
 possible
Date: Thu, 15 Sep 2011 17:25:46 -0400 (EDT)
Message-ID: <20110915.172546.198689956365568711.davem@redhat.com>
References: <1314915000.2733.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934922Ab1IOVZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 17:25:48 -0400
In-Reply-To: <1314915000.2733.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 01 Sep 2011 23:09:59 +0100

> This was originally done as part of commit
> 65f0b417dee94f779ce9b77102b7d73c93723b39 ("sfc: Use write-combining to
> reduce TX latency"), but that had to be reverted.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
