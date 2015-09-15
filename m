From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCHv1 net] xen-netback: require fewer guest Rx
 slots when not using GSO
Date: Tue, 15 Sep 2015 10:15:39 -0700 (PDT)
Message-ID: <20150915.101539.1217301638655614693.davem@davemloft.net>
References: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
	<20150909.123459.1956039261743477106.davem@davemloft.net>
	<55F7F339.4050501@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xenproject.org
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbIORPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 13:15:42 -0400
In-Reply-To: <55F7F339.4050501@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 15 Sep 2015 11:30:17 +0100

> This is causing regressions with certain frontend drivers.  Can you
> drop it, please?

All patches applied to my tree are part of the permanent record, and
this one even made it's way to Linus already I think.

So what you need to do is send me a revert.

Thanks.
