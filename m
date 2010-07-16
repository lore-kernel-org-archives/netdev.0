From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] vxge: Remove queue_state references
Date: Thu, 15 Jul 2010 20:50:37 -0700 (PDT)
Message-ID: <20100715.205037.02261248.davem@davemloft.net>
References: <1279219648-10345-1-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sreenivasa.honnur@exar.com,
	ramkrishna.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934092Ab0GPDuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 23:50:22 -0400
In-Reply-To: <1279219648-10345-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Thu, 15 Jul 2010 13:47:23 -0500

> Remove queue_state references, as they are no longer necessary.
> 
> Also, The driver needs to start/stop the queue regardless of which type
> of steering is enabled.  Remove checks for TX_MULTIQ_STEERING only and
> start/stop for all steering types.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
> Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>

Applied.
