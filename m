From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: expand control flow of macro
 SKIP_NONLOCAL
Date: Wed, 11 Dec 2013 12:29:41 -0500 (EST)
Message-ID: <20131211.122941.2015307496899281847.davem@davemloft.net>
References: <1386680134-85452-7-git-send-email-yangyingliang@huawei.com>
	<20131210.224900.1427512059771492387.davem@davemloft.net>
	<52A81177.6000100@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab3LKR3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 12:29:42 -0500
In-Reply-To: <52A81177.6000100@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 11 Dec 2013 15:17:11 +0800

> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> SKIP_NONLOCAL hides the control flow. The control flow should be
> inlined and expanded explicitly in code so that someone who reads
> it can tell the control flow can be changed by the statement.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

This looks better, applied, thanks.
