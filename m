From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] appletalk: fix checkpatch errors with
 foo* bar|foo * bar
Date: Fri, 14 Feb 2014 16:21:12 -0500 (EST)
Message-ID: <20140214.162112.1352528612452574836.davem@davemloft.net>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com>
	<1392363826-8256-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbaBNVVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:21:14 -0500
In-Reply-To: <1392363826-8256-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 14 Feb 2014 15:43:44 +0800

> fix checkpatch errors below:
> ERROR: "foo* bar" should be "foo *bar"
> ERROR: "foo * bar" should be "foo *bar"
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied.
