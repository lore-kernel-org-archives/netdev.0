From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] cs89x0: Move the driver into the Cirrus dir
Date: Fri, 07 Oct 2011 12:39:36 -0400 (EDT)
Message-ID: <20111007.123936.390761582614065567.davem@davemloft.net>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1317971926-23145-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	nelson@crynwr.com, akpm@linux-foundation.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965451Ab1JGQjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:39:51 -0400
In-Reply-To: <1317971926-23145-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  7 Oct 2011 00:18:33 -0700

> The cs89x0 driver was initial placed in the apple/ when it
> should have been placed in the cirrus/.  This resolves the
> issue by moving the dirver and fixing up the respective
> Kconfig(s) and Makefile(s).
> 
> Thanks to Sascha for reporting the issue.
> 
> CC: Russell Nelson <nelson@crynwr.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: Sascha Hauer <s.hauer@pengutronix.de>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
