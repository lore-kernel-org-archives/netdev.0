From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl_pq_mdio: add module license GPL
Date: Sun, 08 Nov 2009 00:49:24 -0800 (PST)
Message-ID: <20091108.004924.128146896.davem@davemloft.net>
References: <20091106185028.GA5198@www.tglx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33135
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753100AbZKHIs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 03:48:58 -0500
In-Reply-To: <20091106185028.GA5198@www.tglx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 6 Nov 2009 19:50:28 +0100

> or it will taint the kernel and fail to load becuase
> of_address_to_resource() is GPL only.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Applied to net-2.6, thanks.
