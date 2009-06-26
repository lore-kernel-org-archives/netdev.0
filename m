From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl_pq_mdio: Fix fsl_pq_mdio to work with modules
Date: Thu, 25 Jun 2009 20:10:07 -0700 (PDT)
Message-ID: <20090625.201007.46406546.davem@davemloft.net>
References: <1245918219-27299-1-git-send-email-ionut.nicu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ionut.nicu@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48335
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752641AbZFZDKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 23:10:02 -0400
In-Reply-To: <1245918219-27299-1-git-send-email-ionut.nicu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ionut Nicu <ionut.nicu@freescale.com>
Date: Thu, 25 Jun 2009 11:23:39 +0300

> This patch fixes the case when ucc_geth or gianfar are compiled
> as modules. Without this patch the call to phy_connect() fails.
> 
> Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
> Acked-by: Andy Fleming <afleming@freescale.com>

Patch applied, thanks.
