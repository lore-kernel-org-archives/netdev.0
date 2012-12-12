From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Fix accidental reversions.
Date: Tue, 11 Dec 2012 21:28:40 -0500 (EST)
Message-ID: <20121211.212840.2301329872718858686.davem@davemloft.net>
References: <1355279060-24192-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab2LLC2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 21:28:43 -0500
In-Reply-To: <1355279060-24192-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 11 Dec 2012 18:24:20 -0800

> Commit 4ce45e02469c382699f4c5f6df727aea9dd2e1ca
> "bnx2: Add BNX2 prefix to CHIP ID and name macros"
> 
> accidentally reverted 2 commits to use pci_ioumap() and to make
> pci_error_handlers const.  This fixes those mistakes.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
