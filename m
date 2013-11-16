From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: don't change to 802.3ad mode while ARP
 monitor is running
Date: Fri, 15 Nov 2013 20:40:42 -0500 (EST)
Message-ID: <20131115.204042.1434943107870815286.davem@davemloft.net>
References: <5285F12A.6030307@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab3KPBko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 20:40:44 -0500
In-Reply-To: <5285F12A.6030307@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 15 Nov 2013 18:02:18 +0800

> Because the ARP monitor is not support for 802.3ad, but We still
                                 ^^^^^^^

"supported"

No need to capitalize "We".

> could change the mode to 802.3ad from ab mode while ARP monirot
                                                          ^^^^^^^

"monitor"

> is running, it is incorrect.
> 
> So add a check for 802.3ad in bonding_store_mode to fix the problem,
> and make a micro program to simplify the code.

What is a "micro program"?
