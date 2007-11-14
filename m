From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] powerpc: Fix fs_enet module build
Date: Wed, 14 Nov 2007 15:51:12 -0800 (PST)
Message-ID: <20071114.155112.34106808.davem@davemloft.net>
References: <4739EDA8.6020800@scram.de>
	<20071113.210926.97725854.davem@davemloft.net>
	<473AE325.8070901@scram.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-embedded@ozlabs.org, marcelo@kvack.org,
	scottwood@freescale.com, linux-kernel@vger.kernel.org,
	jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org
To: jochen@scram.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753584AbXKNXvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 18:51:12 -0500
In-Reply-To: <473AE325.8070901@scram.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jochen Friedrich <jochen@scram.de>
Date: Wed, 14 Nov 2007 12:59:33 +0100

> I know it's ugly, however, module building is completely
> broken right now and I just want to provide a quick and
> ugly fix until both that ppc->powerpc transition and the
> new binding transition are over. Noone wants to touch the
> old stuff any more as it's a pita and it's already scheduled
> for removal in a couple of months.

Fair enough, I'll apply the patch.

Thanks for the explanation.
