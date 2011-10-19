From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] cs89x0: Move the driver into the Cirrus dir
Date: Tue, 18 Oct 2011 23:42:05 -0400 (EDT)
Message-ID: <20111018.234205.1412280184407630539.davem@davemloft.net>
References: <1318061264-25310-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	nelson@crynwr.com, akpm@linux-foundation.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156Ab1JSDmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:42:19 -0400
In-Reply-To: <1318061264-25310-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  8 Oct 2011 01:07:44 -0700

> The cs89x0 driver was initial placed in the apple/ when it
> should have been placed in the cirrus/.  This resolves the
> issue by moving the dirver and fixing up the respective
> Kconfig(s) and Makefile(s).
> 
> Thanks to Sascha for reporting the issue.
> 
> -v2 Fix a config error that was introduced with v1 by removing
>     the dependency on MACE for NET_VENDOR_APPLE.
> 
> CC: Russell Nelson <nelson@crynwr.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: Sascha Hauer <s.hauer@pengutronix.de>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
