From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend net-next] mac802154: fix following checkpath.pl
 warning Prefer pr_warn(... to pr_warning(...
Date: Sun, 22 Dec 2013 18:53:21 -0500 (EST)
Message-ID: <20131222.185321.1723174630802684668.davem@davemloft.net>
References: <1387359364-5892-1-git-send-email-chenweilong@huawei.com>
	<52B24A52.9010105@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756649Ab3LVXxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:53:23 -0500
In-Reply-To: <52B24A52.9010105@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chenweilong <chenweilong@huawei.com>
Date: Thu, 19 Dec 2013 09:22:26 +0800

> From: Weilong Chen <chenweilong@huawei.com>
> 
> This patch fixes checkpath.pl:
>  WARNING: Prefer pr_warn(... to pr_warning(...
>  #447: FILE: ./wpan.c:447:
> 
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>

Applied, thanks.
