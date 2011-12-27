From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ucc_geth: some fix in current kernel
Date: Tue, 27 Dec 2011 12:59:40 -0500 (EST)
Message-ID: <20111227.125940.1585324652948148302.davem@davemloft.net>
References: <y>
	<1324979328-32081-1-git-send-email-X.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	leoli@freescale.com, Haiying.Wang@freescale.com
To: X.Xie@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689Ab1L0SBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 13:01:53 -0500
In-Reply-To: <1324979328-32081-1-git-send-email-X.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xie Xiaobo <X.Xie@freescale.com>
Date: Tue, 27 Dec 2011 17:48:48 +0800

> * Revert commit "ucc_geth: Fix hangs after switching from full to half duplex"
>   This commit impacted the driver in all link state change more than
>   duplex change.
> * Change some parameters.
>   Increased the BD ring length.
> 
> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
> Signed-off-by: Xie Xiaobo <X.Xie@freescale.com>

Please, one major change per patch.
