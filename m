From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/7] gianfar: Add per queue structure support
Date: Mon, 26 Oct 2009 16:07:23 -0700 (PDT)
Message-ID: <20091026.160723.40116800.davem@davemloft.net>
References: <1256574433500-git-send-email-sandeep.kumar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sandeep.kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55303
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753987AbZJZXHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:07:00 -0400
In-Reply-To: <1256574433500-git-send-email-sandeep.kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set still doesn't apply cleanly to net-next-2.6,
in particular patch #4 fails to apply:

Applying: fsl_pq_mdio: Add Suport for etsec2.0 devices.
error: patch failed: drivers/net/fsl_pq_mdio.c:405
error: drivers/net/fsl_pq_mdio.c: patch does not apply
Patch failed at 0004 fsl_pq_mdio: Add Suport for etsec2.0 devices.
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

Please respin this, and also please CC: on all of your patch
postings as that helps me sort things.

Thanks.
