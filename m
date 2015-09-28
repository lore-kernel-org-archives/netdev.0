From: David Miller <davem@davemloft.net>
Subject: Re: request for stable inclusion
Date: Mon, 28 Sep 2015 16:14:35 -0700 (PDT)
Message-ID: <20150928.161435.475311852503496615.davem@davemloft.net>
References: <55F90F24.5010601@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clsoto@us.ibm.com, matanb@mellanox.com, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbI1XOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 19:14:38 -0400
In-Reply-To: <55F90F24.5010601@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 16 Sep 2015 09:41:40 +0300

> Hi Dave,
> 
> Commit 9293267 "net/mlx4_core: Capping number of requested MSIXs to
> MAX_MSIX" fixes a bug under which the driver doesn't really starts
> over a machine with > 32 cores.
> 
> The bug was introduced in 4.2-rc1 but the fix missed 4.2 -- could you
> please push it to 4.2 -stable?

Queued up, thanks.
