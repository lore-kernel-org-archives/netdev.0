From: David Miller <davem@davemloft.net>
Subject: Re: [requrest for stable 4.1.y inclution] Fix for CVE-2015-7799
Date: Fri, 15 Jan 2016 16:00:18 -0500 (EST)
Message-ID: <20160115.160018.1581856659181409876.davem@davemloft.net>
References: <56978CFE.1010703@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: machida.yuki@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbcAOVAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 16:00:20 -0500
In-Reply-To: <56978CFE.1010703@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Date: Thu, 14 Jan 2016 20:56:46 +0900

> This patch is the fix for CVE-2015-7799
> Upstream commit 4ab42d78e37a294ac7bc56901d563c642e03c4ae
> 
> Stable 3.2.y has included this patch in v3.2.75.
> https://cdn.kernel.org/pub/linux/kernel/v3.x/ChangeLog-3.2.75
> 
> Please include in this patch to stable 4.1.y.

Ok, queued up for -stable, thanks.
