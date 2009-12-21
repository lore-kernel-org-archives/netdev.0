From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix bnx2_netif_stop() merge error.
Date: Sun, 20 Dec 2009 18:41:15 -0800 (PST)
Message-ID: <20091220.184115.189684563.davem@davemloft.net>
References: <1261333847-15334-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752424AbZLUClQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2009 21:41:16 -0500
In-Reply-To: <1261333847-15334-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 20 Dec 2009 10:30:47 -0800

> The error was introduced while merging:
> 
> commit 4529819c45161e4a119134f56ef504e69420bc98
> bnx2: reset_task is crashing the kernel. Fixing it.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

That's the last, and very last, time I merge in a patch
that git rejects but 'patch' accepts.

Even if it's just line differences and 'fuzz' I'm pushing
the patch back at the submitter.

Thanks for the fix Michael.
