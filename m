From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] bnx2x: fix 57840_MF pci id
Date: Thu, 30 Aug 2012 13:13:15 -0400 (EDT)
Message-ID: <20120830.131315.2289996886162431257.davem@davemloft.net>
References: <1345977345-3721-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, mchan@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab2H3RNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:13:19 -0400
In-Reply-To: <1345977345-3721-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 26 Aug 2012 13:35:45 +0300

> Commit c3def943c7117d42caaed3478731ea7c3c87190e have added support for
> new pci ids of the 57840 board, while failing to change the obsolete value
> in 'pci_ids.h'. 
> This patch does so, allowing the probe of such devices.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
