From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net_sched: do some cleanup
Date: Tue, 31 Dec 2013 13:51:47 -0500 (EST)
Message-ID: <20131231.135147.28209841155071021.davem@davemloft.net>
References: <1387791540-27028-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832Ab3LaSvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 13:51:48 -0500
In-Reply-To: <1387791540-27028-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Mon, 23 Dec 2013 17:38:57 +0800

> Prefer pr_warn(... to pr_warning(...
> Do not use C99 // comments and fix spelling.
> Correct function names by using __func__ .

Series applied, thanks.
