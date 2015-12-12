From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Handle clip return values
Date: Fri, 11 Dec 2015 20:15:34 -0500 (EST)
Message-ID: <20151211.201534.354331798657050762.davem@davemloft.net>
References: <1449661595-5745-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbLLBPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:15:36 -0500
In-Reply-To: <1449661595-5745-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  9 Dec 2015 17:16:35 +0530

> Add a warn message when clip table overflows. If clip table isn't
> allocated, return from cxgb4_clip_release() to avoid panic.
> Disable offload if clip isn't enabled in the hardware.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
