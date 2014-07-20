From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] libcxgbi:cxgb4i Guard ipv6 code with a config
 check
Date: Sun, 20 Jul 2014 00:46:11 -0700 (PDT)
Message-ID: <20140720.004611.2145097056679931630.davem@davemloft.net>
References: <1405647284-498-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kxie@chelsio.com, manojmalviya@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbaGTHqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 03:46:14 -0400
In-Reply-To: <1405647284-498-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu, 17 Jul 2014 18:34:44 -0700

> Fixes: fc8d0590d914 ("libcxgbi: Add ipv6 api to driver")
> Fixes: 759a0cc5a3e1 ("cxgb4i: Add ipv6 code to driver, call into libcxgbi ipv6
> api")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
