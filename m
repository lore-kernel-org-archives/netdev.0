From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers: net : cpsw: Use netdev_name while
 requesting irq
Date: Mon, 09 Dec 2013 19:57:06 -0500 (EST)
Message-ID: <20131209.195706.1978243618769759438.davem@davemloft.net>
References: <1386313107-8597-1-git-send-email-mugunthanvnm@ti.com>
	<20131206.154640.2274056773488827363.davem@davemloft.net>
	<52A58D61.9060404@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	george.cherian@ti.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab3LJA5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 19:57:08 -0500
In-Reply-To: <52A58D61.9060404@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Mon, 9 Dec 2013 14:59:05 +0530

> commit 50a5fb068

This commit doesn't appear in any tree.

And any change which makes a real "struct device" return NULL
for dev_name() is broken.

I'm not applying this patch, you have completely failed to
provide any information necessary to support and justify
your change.
