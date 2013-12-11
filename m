From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_htb: remove unnecessary NULL pointer
 judgment
Date: Wed, 11 Dec 2013 15:30:49 -0500 (EST)
Message-ID: <20131211.153049.2165189149854834261.davem@davemloft.net>
References: <1386748117-27072-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab3LKUau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:30:50 -0500
In-Reply-To: <1386748117-27072-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 11 Dec 2013 15:48:37 +0800

> It already has a NULL pointer judgment of rtab in qdisc_put_rtab().
> Remove the judgment outside of qdisc_put_rtab().
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied.
