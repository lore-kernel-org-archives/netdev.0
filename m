From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Get TID calculation right for IPv6 mode
Date: Thu, 24 Dec 2015 11:05:58 -0500 (EST)
Message-ID: <20151224.110558.469953952361138694.davem@davemloft.net>
References: <1450953917-30876-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179AbbLXQGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 11:06:00 -0500
In-Reply-To: <1450953917-30876-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 24 Dec 2015 16:15:17 +0530

> CLIP is always enabled and hardware uses 2 TID entries instead of 4 for
> IPv6 in CLIP mode.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
