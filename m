From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix 5717 serdes powerdown problem
Date: Mon, 02 Apr 2012 17:42:21 -0400 (EDT)
Message-ID: <20120402.174221.284795608218672285.davem@davemloft.net>
References: <1333393300-5102-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258Ab2DBVmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 17:42:24 -0400
In-Reply-To: <1333393300-5102-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 2 Apr 2012 12:01:40 -0700

> If port 0 of a 5717 serdes device powers down, it hides the phy from
> port 1.  This patch works around the problem by keeping port 0's phy
> powered up.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied and queued up for -stable, thanks.
