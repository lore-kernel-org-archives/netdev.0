From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: use pci_dev->subsystem_{vendor|device}
Date: Fri, 22 Jul 2011 17:15:09 -0700 (PDT)
Message-ID: <20110722.171509.936775923431019840.davem@davemloft.net>
References: <201107221937.24383.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com, romieu@fr.zoreil.com
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756134Ab1GWAPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 20:15:20 -0400
In-Reply-To: <201107221937.24383.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Fri, 22 Jul 2011 19:37:24 +0400

> The driver reads PCI subsystem IDs from the PCI configuration registers while
> they are already stored by the PCI subsystem in the 'subsystem_{vendor|device}'
> fields of 'struct pci_dev'...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied.
