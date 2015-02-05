From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix NAPI poll routine for Tx completion
Date: Thu, 05 Feb 2015 00:24:23 -0800 (PST)
Message-ID: <20150205.002423.141006385880288311.davem@davemloft.net>
References: <1423046485-9526-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbbBEIYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:24:23 -0500
In-Reply-To: <1423046485-9526-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Wed, 4 Feb 2015 05:41:25 -0500

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> After d75b1ade567f ("net: less interrupt masking in NAPI")
> driver's NAPI poll routine is expected to return
> exact budget value if it wants to be re-called.
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Fixes: d75b1ade567f ("net: less interrupt masking in NAPI")

Applied, thanks.
