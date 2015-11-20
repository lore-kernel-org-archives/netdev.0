From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: encx24j600: move rev announcement to
 probe function
Date: Fri, 20 Nov 2015 10:45:45 -0500 (EST)
Message-ID: <20151120.104545.932582494144233754.davem@davemloft.net>
References: <1447881741-30386-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jringle@gridpoint.com
To: jon@ringle.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760608AbbKTPpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 10:45:51 -0500
In-Reply-To: <1447881741-30386-1-git-send-email-jon@ringle.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jon@ringle.org
Date: Wed, 18 Nov 2015 16:22:21 -0500

> From: Jon Ringle <jringle@gridpoint.com>
> 
> When encx24j600 is open and closed many times due to userspace polling the
> interface, the log gets noise with this log message.
> 
> Moving this to encx24j600_spi_probe function where it belongs.
> 
> Signed-off-by: Jon Ringle <jringle@gridpoint.com>

Applied, thanks.
