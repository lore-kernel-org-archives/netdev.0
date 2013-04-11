From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Mellanox Ethernet driver updates
 2013-04-11
Date: Thu, 11 Apr 2013 16:13:18 -0400 (EDT)
Message-ID: <20130411.161318.1987281607383961258.davem@davemloft.net>
References: <1365681402-19445-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab3DKUNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 16:13:20 -0400
In-Reply-To: <1365681402-19445-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 11 Apr 2013 14:56:39 +0300

> This series contains updates to mlx4 driver.
> First two patches enable SRIOV guests running old mlx4 drivers with B0 steering
> only to run over hypervisor with new drivers that is using device managed flow
> steering (DMFS).
> Third patch is a fix to set corret MTU in SRIOV.

All applied to net-next, thanks.
