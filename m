From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] net_sched: sfq: put sfq_unlink in a do -
 while loop
Date: Tue, 10 Dec 2013 22:47:01 -0500 (EST)
Message-ID: <20131210.224701.620230845506977502.davem@davemloft.net>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
	<1386680134-85452-6-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab3LKDrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:47:02 -0500
In-Reply-To: <1386680134-85452-6-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Tue, 10 Dec 2013 20:55:33 +0800

> Macros with multiple statements should be enclosed in a do - while loop
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied.
