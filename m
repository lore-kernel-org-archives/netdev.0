From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] [v3] netlink_kernel_create updates
Date: Sat, 08 Sep 2012 19:16:26 -0400 (EDT)
Message-ID: <20120908.191626.1983652914856307985.davem@davemloft.net>
References: <1347108834-15429-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841Ab2IHXQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 19:16:27 -0400
In-Reply-To: <1347108834-15429-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Sat,  8 Sep 2012 14:53:52 +0200

> Fixed the infiniband issue. New round of these patches.
 ...
> Pablo Neira Ayuso (2):
>   netlink: kill netlink_set_nonroot
>   netlink: hide struct module parameter in netlink_kernel_create

All applied to net-next, thanks.
