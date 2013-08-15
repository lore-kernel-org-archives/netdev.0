From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx5_core: Support MANAGE_PAGES and QUERY_PAGES
 firmware command changes
Date: Thu, 15 Aug 2013 15:43:26 -0700 (PDT)
Message-ID: <20130815.154326.1210349589203812390.davem@davemloft.net>
References: <1376491608-3759-1-git-send-email-moshel@mellanox.com>
	<20130815.014837.1103024579636450520.davem@davemloft.net>
	<520C9CD7.1090400@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: moshel@mellanox.com, netdev@vger.kernel.org, roland@kernel.org,
	eli@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481Ab3HOWn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 18:43:27 -0400
In-Reply-To: <520C9CD7.1090400@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 15 Aug 2013 12:18:15 +0300

> This commit fixes an issue (bug) which we find in testing done on the
> code/firmware used for the initial merge, xxit happens, indeed. All in
> all, we understand that moving forward, after the initial FW GA or the
> release of 3.11, we will have to maintain FW/driver compatibility.

Ok, since 3.11 is the first release of the driver, this is ok.

Thanks for explaining, applied.
