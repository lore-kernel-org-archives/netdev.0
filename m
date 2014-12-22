From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] 8139too: Add netif_napi_del in the driver
Date: Mon, 22 Dec 2014 16:32:19 -0500 (EST)
Message-ID: <20141222.163219.179884572957836103.davem@davemloft.net>
References: <1419208994-23908-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: baijiaju1990@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755708AbaLVVcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:32:21 -0500
In-Reply-To: <1419208994-23908-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Mon, 22 Dec 2014 08:43:14 +0800

> For linux-3.18.0
> The driver lacks netif_napi_del in the normal path and error path
> to match the call of netif_napi_add in rtl8139_init_one.
> This patch fixes this problem.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied.
