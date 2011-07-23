From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sbni: use pci_dev->subsystem_device
Date: Fri, 22 Jul 2011 17:15:17 -0700 (PDT)
Message-ID: <20110722.171517.1347031469291763996.davem@davemloft.net>
References: <201107221950.25960.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab1GWAPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 20:15:20 -0400
In-Reply-To: <201107221950.25960.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Fri, 22 Jul 2011 19:50:25 +0400

> The driver reads PCI subsystem ID from the PCI configuration register while it's
> already stored by the PCI subsystem in the 'subsystem_device' field of 'struct
> pci_dev'...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied.
