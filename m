From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net_sched: remove unnecessary null
 pointer check
Date: Thu, 19 Dec 2013 15:07:48 -0500 (EST)
Message-ID: <20131219.150748.839670108142642890.davem@davemloft.net>
References: <1387265357-19352-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755255Ab3LSUHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:07:50 -0500
In-Reply-To: <1387265357-19352-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Tue, 17 Dec 2013 15:29:15 +0800

> Remove unnecessary null pointer check outside of qdisc_put_rtab().

Series applied, thanks.
