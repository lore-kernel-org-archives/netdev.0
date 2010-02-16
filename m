From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 2/6] bnx2: Need to call
 cnic_setup_cnic_irq_info() after MTU change.
Date: Tue, 16 Feb 2010 15:20:13 -0800 (PST)
Message-ID: <20100216.152013.38344794.davem@davemloft.net>
References: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
	<1266298932-28129-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32832
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933354Ab0BPXT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:19:58 -0500
In-Reply-To: <1266298932-28129-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 15 Feb 2010 21:42:08 -0800

> New status blocks are allocated during MTU change so we need to
> update this information for the cnic driver.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
