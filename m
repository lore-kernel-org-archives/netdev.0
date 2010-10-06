From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bna: fix interrupt handling
Date: Tue, 05 Oct 2010 20:40:57 -0700 (PDT)
Message-ID: <20101005.204057.260087756.davem@davemloft.net>
References: <1286329565-20234-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, ddutt@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57991
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756934Ab0JFDkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:40:36 -0400
In-Reply-To: <1286329565-20234-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 5 Oct 2010 18:46:04 -0700

> This fix handles the case when IRQ handler is called (for shared IRQs)
> even before the driver is ready to handle interrupts.
> 
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied.
