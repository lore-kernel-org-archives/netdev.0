From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Add missing bit in default Tx switching
Date: Thu, 27 Feb 2014 17:16:49 -0500 (EST)
Message-ID: <20140227.171649.1693930241530644358.davem@davemloft.net>
References: <1393508546-8489-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaB0WQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:16:51 -0500
In-Reply-To: <1393508546-8489-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Thu, 27 Feb 2014 15:42:26 +0200

> Commit c14db2025 "bnx2x: Correct default Tx switching behaviour" supposedly
> changed the default Tx switching behaviour, but was missing the fastpath change
> required for FW to pass packets from PFs to VFs.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied, thank you.
