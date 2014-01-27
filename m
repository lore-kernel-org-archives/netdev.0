From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH net-next v5] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Mon, 27 Jan 2014 13:09:21 -0800 (PST)
Message-ID: <20140127.130921.7056971883805642.davem@davemloft.net>
References: <1390731147-2424-1-git-send-email-Annie.li@oracle.com>
	<52E63382.6090503@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Annie.li@oracle.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbaA0VJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 16:09:22 -0500
In-Reply-To: <52E63382.6090503@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Mon, 27 Jan 2014 10:22:58 +0000

> I think this should be applied to net (and tagged as a stable candidate)
> rather than net-next as this fixes are very big resource leak.

Then this subject line and commit message must be fixed to make it clear
that this is a BUG fix, rather then just a "clean up".
