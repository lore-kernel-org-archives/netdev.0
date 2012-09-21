From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: change return values from -EACCES to -EPERM
Date: Fri, 21 Sep 2012 13:58:35 -0400 (EDT)
Message-ID: <20120921.135835.688484424385838589.davem@davemloft.net>
References: <505C2745.4080704@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serge.hallyn@canonical.com,
	ebiederm@xmission.com
To: zhaohongjiang37@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756921Ab2IUR6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:58:37 -0400
In-Reply-To: <505C2745.4080704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhao Hongjiang <zhaohongjiang37@gmail.com>
Date: Fri, 21 Sep 2012 16:37:25 +0800

> From: Zhao Hongjiang <zhaohongjiang@huawei.com>
> 
> Change return value from -EACCES to -EPERM when the permission check fails.
> 
> Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>

Applied, thank you.
