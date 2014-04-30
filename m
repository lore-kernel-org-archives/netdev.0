From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sxgbe: sw reset moved to probe function
Date: Wed, 30 Apr 2014 16:14:54 -0400 (EDT)
Message-ID: <20140430.161454.9517336091176344.davem@davemloft.net>
References: <001b01cf6361$9f4b6650$dde232f0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	ks.giri@samsung.com, vipul.pandya@samsung.com
To: bh74.an@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965044AbaD3UOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:14:55 -0400
In-Reply-To: <001b01cf6361$9f4b6650$dde232f0$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Byungho An <bh74.an@samsung.com>
Date: Tue, 29 Apr 2014 13:15:15 +0900

> 
> This patch moves sw reset to probe function because
> sw reset is needed early stage before open function.
> 
> Signed-off-by: Byungho An <bh74.an@samsung.net>

Applied.
