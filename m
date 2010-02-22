From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] can: ti hecc module : add platform specific
 initialization callback.
Date: Mon, 22 Feb 2010 15:47:41 -0800 (PST)
Message-ID: <20100222.154741.56894014.davem@davemloft.net>
References: <1266845762-7809-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	anantgole@ti.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751961Ab0BVXrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:47:23 -0500
In-Reply-To: <1266845762-7809-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan <srk@ti.com>
Date: Mon, 22 Feb 2010 19:06:02 +0530

> CAN module on AM3517 requires programming of IO expander as part
> of init sequence - to enable CAN PHY. Added platform specific
> init callback to handle this.
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>
> Acked-by: Anant Gole <anantgole@ti.com>

Please address Wolfgang's feedback comments.

Thanks.
