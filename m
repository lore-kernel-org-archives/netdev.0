From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] MPC85xx: Add UCC6 and UCC8 nodes in SGMII mode for
 MPC8569MDS
Date: Wed, 03 Jun 2009 03:51:32 -0700 (PDT)
Message-ID: <20090603.035132.157926180.davem@davemloft.net>
References: <1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com>
	<1243951456-4685-3-git-send-email-Haiying.Wang@freescale.com>
	<1243951456-4685-4-git-send-email-Haiying.Wang@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Haiying.Wang@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52915
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751484AbZFCKvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 06:51:32 -0400
In-Reply-To: <1243951456-4685-4-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiying Wang <Haiying.Wang@freescale.com>
Date: Tue,  2 Jun 2009 10:04:16 -0400

> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>

I couldn't apply this to net-next-2.6 because this DTS
file being patched doesn't exist there.

Perhaps the powerpc-next tree can suck it in...
