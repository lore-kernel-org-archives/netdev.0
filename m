From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net-next:asix: V2 more fixes for ax88178 phy init
 sequence
Date: Tue, 15 Nov 2011 16:42:02 -0500 (EST)
Message-ID: <20111115.164202.810749392412257566.davem@davemloft.net>
References: <1321377163-26308-1-git-send-email-grundler@chromium.org>
	<1321377163-26308-4-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, freddy@asix.com.tw, grundler@google.com
To: grundler@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504Ab1KOVmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 16:42:07 -0500
In-Reply-To: <1321377163-26308-4-git-send-email-grundler@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@chromium.org>
Date: Tue, 15 Nov 2011 09:12:42 -0800

> From: Grant Grundler <grundler@google.com>
> 
> Now works on Samsung Series 5 (chromebook)
> 
> Two fixes here:
> o use 0x7F mask for phymode
> o read phyid *AFTER* phy is powered up (via GPIOs)
> 
> Signed-off-by: Allan Chou <allan@asix.com.tw>
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied.
