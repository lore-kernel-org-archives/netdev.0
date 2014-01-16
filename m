From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: create helper function to
 enable|disable sackdelay
Date: Wed, 15 Jan 2014 16:48:54 -0800 (PST)
Message-ID: <20140115.164854.408974533162424968.davem@davemloft.net>
References: <52D653B1.4040708@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbaAPAsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:48:55 -0500
In-Reply-To: <52D653B1.4040708@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 15 Jan 2014 17:24:01 +0800

> add sctp_spp_sackdelay_{enable|disable} helper function for
> avoiding code duplication. 
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied.
