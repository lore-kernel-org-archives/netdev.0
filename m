From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lanai: use pci_dev->subsystem_device
Date: Tue, 12 Jul 2011 07:59:49 -0700 (PDT)
Message-ID: <20110712.075949.2203046681846313949.davem@davemloft.net>
References: <201107121847.57793.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725Ab1GLPCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 11:02:03 -0400
In-Reply-To: <201107121847.57793.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Tue, 12 Jul 2011 18:47:57 +0400

> The driver reads PCI subsystem IDs from the PCI configuration registers while
> it is already stored by the PCI subsystem in the 'subsystem_device' field of
> 'struct pci_dev'...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied to net-next-2.6, thanks.
