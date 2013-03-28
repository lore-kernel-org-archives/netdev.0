From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: fix compilation without
 CONFIG_BNX2X_SRIOV
Date: Wed, 27 Mar 2013 23:26:42 -0400 (EDT)
Message-ID: <20130327.232642.1821114868784632446.davem@davemloft.net>
References: <1364410570-18129-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab3C1D0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 23:26:43 -0400
In-Reply-To: <1364410570-18129-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 27 Mar 2013 20:56:10 +0200

> Move mutex initialization by allocation of the mailbox it protects.
> 
> introduced in commit 1d6f3cd89 'bnx2x: Prevent VF race'
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>

Applied, thanks.
