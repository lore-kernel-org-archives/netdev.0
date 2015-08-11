From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix fdb_dump index calculation
Date: Mon, 10 Aug 2015 21:15:36 -0700 (PDT)
Message-ID: <20150810.211536.2264386202001074264.davem@davemloft.net>
References: <871tfb6wdu.wl%atzm@iij.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: atzm@iij.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbbHKEPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:15:38 -0400
In-Reply-To: <871tfb6wdu.wl%atzm@iij.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atzm Watanabe <atzm@iij.ad.jp>
Date: Mon, 10 Aug 2015 23:39:09 +0900

> When too many remotes are bound to an FDB entry, index may not be increased.
> This problem will be caused on the large scale environment that is based on
> the unicast default destination, for instance.
> 
> Signed-off-by: Atzm Watanabe <atzm@iij.ad.jp>

Applied, thank you.
