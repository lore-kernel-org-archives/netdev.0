From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/6] bnx2: Check BNX2_FLAG_USING_MSIX flag when
 setting up MSIX.
Date: Tue, 16 Feb 2010 15:20:05 -0800 (PST)
Message-ID: <20100216.152005.98313418.davem@davemloft.net>
References: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32827
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933354Ab0BPXTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:19:50 -0500
In-Reply-To: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 15 Feb 2010 21:42:07 -0800

> Checking the flag is more correct than checking bp->irq_nvecs. By
> accident it is not a problem because we always have more than 1
> vectors when using MSIX mode.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
