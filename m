From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/5] Mellanox driver updates 2013-08-19
Date: Wed, 21 Aug 2013 12:20:03 -0700 (PDT)
Message-ID: <20130821.122003.81145207852022011.davem@davemloft.net>
References: <1377068939-17561-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289Ab3HUTUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 15:20:12 -0400
In-Reply-To: <1377068939-17561-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed, 21 Aug 2013 10:08:54 +0300

> This small patchset contains 2 fixes to bad handling of error flows in TX
> datapath, and a fix to a bug in mlx4_en_dcbnl_ieee_setpfc() where global pause
> frames were enabled whenever PFC was configured.
> Also added a patch to reduce the scope of some local variables in the moved
> block of code and it's surrounding.

Series applied, thanks.
