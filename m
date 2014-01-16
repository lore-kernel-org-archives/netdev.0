From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 Net-next] ixgbe: define IXGBE_MAX_VFS_DRV_LIMIT
 macro and cleanup const 63
Date: Wed, 15 Jan 2014 21:57:53 -0800 (PST)
Message-ID: <20140115.215753.1619877365795484712.davem@davemloft.net>
References: <52D75F1D.9040405@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aaron.f.brown@intel.com, jeffrey.t.kirsher@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ethan.kernel@gmail.com
To: ethan.zhao@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbaAPF5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 00:57:54 -0500
In-Reply-To: <52D75F1D.9040405@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ethan zhao <ethan.zhao@oracle.com>
Date: Thu, 16 Jan 2014 12:25:01 +0800

> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
> Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>

Please don't give two signoffs for yourself, it is not appropriate at
all.

I am very genuinely curious where you got the idea to do that,
particularly as I've never seen anyone else do it before.  So it's
really not possible that you got the idea from someone else's actions.
