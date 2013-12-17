From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fddi: cleanup unsigned to unsigned int/short
Date: Mon, 16 Dec 2013 20:11:37 -0500 (EST)
Message-ID: <20131216.201137.726847705667446117.davem@davemloft.net>
References: <52AAAE14.9000301@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arend@broadcom.com, joe@perches.com, netdev@vger.kernel.org
To: tanxiaojun@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682Ab3LQBLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 20:11:39 -0500
In-Reply-To: <52AAAE14.9000301@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: tanxiaojun <tanxiaojun@huawei.com>
Date: Fri, 13 Dec 2013 14:49:56 +0800

> Use "unsigned int/short" instead of "unsigned", and change the type of
> iteration variable "i" to "unsigned int".
> 
> Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>

Applied.
