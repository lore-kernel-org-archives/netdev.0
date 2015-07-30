From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix compilation when
 CONFIG_BNX2X_SRIOV is not set
Date: Thu, 30 Jul 2015 09:52:30 -0700 (PDT)
Message-ID: <20150730.095230.97071113304255092.davem@davemloft.net>
References: <1438255829-27326-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbbG3Qwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 12:52:33 -0400
In-Reply-To: <1438255829-27326-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 30 Jul 2015 14:30:29 +0300

> Commit 05cc5a39ddb7 ("bnx2x: add vlan filtering offload") has broken
> compilation when CONFIG_BNX2X_SRIOV is not set.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied.
