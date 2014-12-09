From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dummy: add support for ethtool get_drvinfo
Date: Tue, 09 Dec 2014 16:07:26 -0500 (EST)
Message-ID: <20141209.160726.984535504729715315.davem@davemloft.net>
References: <1417824804-20634-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbaLIVH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:07:28 -0500
In-Reply-To: <1417824804-20634-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Fri,  5 Dec 2014 22:13:24 -0200

> The command 'ethtool -i' is useful to find details
> about the interface like the device driver being used.
> This was missing for dummy driver.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied, thank you.

Consider adding a MODULE_VERSION instance since you've added an
explicit version.

Thanks.
