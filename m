From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: netx-eth: remove unnecessary casting
Date: Wed, 04 Sep 2013 00:53:51 -0400 (EDT)
Message-ID: <20130904.005351.2261364821750378506.davem@davemloft.net>
References: <004b01cea774$975b48b0$c611da10$%han@samsung.com>
	<001101cea837$b49bf370$1dd3da50$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756021Ab3IDExw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:53:52 -0400
In-Reply-To: <001101cea837$b49bf370$1dd3da50$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 03 Sep 2013 08:54:04 +0900

> Casting from 'void *' is unnecessary, because casting from 'void *'
> to any pointer type is automatic.
> 
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
