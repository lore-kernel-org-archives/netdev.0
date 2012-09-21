From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/1] Add support of ECMPv6
Date: Fri, 21 Sep 2012 13:48:33 -0400 (EDT)
Message-ID: <20120921.134833.1294721941180523200.davem@davemloft.net>
References: <20120920.171525.2005584636029506440.davem@davemloft.net>
	<1348221545-14747-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bernat@luffy.cx, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344Ab2IURsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:48:35 -0400
In-Reply-To: <1348221545-14747-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 21 Sep 2012 11:59:04 +0200

> v4: remove compilation options to choose multipath algorithm for next hop
>     selection. Now the choice can be done at run time via
>     /proc/sys/net/ipv6/route/multipath_algorithm

Please specify this in the routing configuration protocol, rather than
via some obscure procfs file.

Thanks.
