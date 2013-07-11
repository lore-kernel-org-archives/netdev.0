From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ifb: fix oops when loading the ifb failed
Date: Thu, 11 Jul 2013 12:00:48 -0700 (PDT)
Message-ID: <20130711.120048.2069760265299932780.davem@davemloft.net>
References: <51DE9126.5040703@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, edumazet@google.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463Ab3GKTAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 15:00:49 -0400
In-Reply-To: <51DE9126.5040703@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 11 Jul 2013 19:04:06 +0800

> If __rtnl_link_register() return faild when loading the ifb, it will
> take the wrong path and get oops, so fix it just like dummy.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
