From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] bnx2x, cnic, bnx2fc: add support for BD
Date: Thu, 06 Aug 2015 21:54:29 -0700 (PDT)
Message-ID: <20150806.215429.1576532174279680769.davem@davemloft.net>
References: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, James.bottomley@HansenPartnership.com,
	linux-scsi-owner@vger.kernel.org, chad.dupuis@qlogic.com,
	Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbbHGEya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 00:54:30 -0400
In-Reply-To: <1438670250-20130-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 4 Aug 2015 09:37:26 +0300

> Commit 230d00eb4bfe ("bnx2x: new Multi-function mode - BD") added support
> for a new multi-function mode, but it added only the support required by
> bnx2x for L2 interfaces.
> 
> This adds the required changes to support the new multi-function mode in
> the offloaded storage protocols.
> 
> Dave,
> 
> Please consider applying this series to `net-next'.
> 
> Do notice that this involves non-networking driver changes -
> but sending this as a single series seemed like the best approach as
> we had to have bnx2x changes to support the new functionality.
> If this is problematic, please tell us what's the preferred solution here.

Series applied, thanks.
