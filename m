From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] bnx2: Read iSCSI config from shared
 memory during ->probe()
Date: Thu, 14 Jul 2011 08:46:51 -0700 (PDT)
Message-ID: <20110714.084651.2197974534430801409.davem@davemloft.net>
References: <1310613862-27497-4-git-send-email-mchan@broadcom.com>
	<1310613862-27497-5-git-send-email-mchan@broadcom.com>
	<1310613862-27497-6-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755137Ab1GNPqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 11:46:53 -0400
In-Reply-To: <1310613862-27497-6-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 13 Jul 2011 20:24:22 -0700

> The scratchpad location that we were reading from has not been
> initialized yet during ->probe(), so we were getting inaccurate
> information.
> 
> Update version to 2.1.10.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
