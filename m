From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix compilation when
 CONFIG_BNX2X_SRIOV is not set
Date: Thu, 27 Mar 2014 14:29:28 -0400 (EDT)
Message-ID: <20140327.142928.214014917230194194.davem@davemloft.net>
References: <1395817589-22890-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441AbaC0S3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 14:29:34 -0400
In-Reply-To: <1395817589-22890-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 26 Mar 2014 09:06:29 +0200

> Commit 370d4a26 "bnx2x: Create workqueue for IOV related tasks" breaks bnx2x
> compilation when CONFIG_BNX2X_SRIOV is not set - "multiple definition of
> `bnx2x_schedule_iov_task'".
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
