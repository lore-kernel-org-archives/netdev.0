From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 v3 3/5] gianfar: Use interface name in
 interrupt name to distinguish the source.
Date: Wed, 17 Dec 2008 16:53:00 -0800 (PST)
Message-ID: <20081217.165300.154830946.davem@davemloft.net>
References: <1229550175-15600-1-git-send-email-afleming@freescale.com>
	<1229550175-15600-2-git-send-email-afleming@freescale.com>
	<1229550175-15600-3-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, Dai.Haruki@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbYLRAw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:52:59 -0500
In-Reply-To: <1229550175-15600-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 17 Dec 2008 15:42:53 -0600

> Interface name (ex. eth0) is used as the prefix for the interrupt name,
> with _rx, _tx, and _er appended to distinguish multiple interrupts on
> the same interface.
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
