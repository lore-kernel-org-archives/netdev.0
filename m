From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: alloc the structure ad_info
 dynamically in per slave
Date: Wed, 14 May 2014 14:09:29 -0400 (EDT)
Message-ID: <20140514.140929.1272438231645943490.davem@davemloft.net>
References: <5370737B.5060700@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbaENSJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:09:31 -0400
In-Reply-To: <5370737B.5060700@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Mon, 12 May 2014 15:08:43 +0800

> The struct ad_slave_info is very huge, and only be used for 802.3ad mode,
> so alloc the structure dynamically could save 356 Bits for every slave in
> non 802.3ad mode.
> 
> Cc: Jay Vosburgh <j.vosburgh@gmail.com>
> Cc: Veaceslav Falico <vfalico@gmail.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thank you.
