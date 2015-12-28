From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] Driver for IBM System i/p VNIC protocol
Date: Mon, 28 Dec 2015 00:12:49 -0500 (EST)
Message-ID: <20151228.001249.1417336567416640306.davem@davemloft.net>
References: <1450718766-22605-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	nfont@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	nguyendo@us.ibm.com, formosa@us.ibm.com, tyreld@linux.vnet.ibm.com,
	jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbL1FNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 00:13:21 -0500
In-Reply-To: <1450718766-22605-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Mon, 21 Dec 2015 11:26:06 -0600

> This is a new device driver for a high performance SR-IOV assisted virtual
> network for IBM System p and IBM System i systems.  The SR-IOV VF will be
> attached to the VIOS partition and mapped to the Linux client via the
> hypervisor's VNIC protocol that this driver implements.
> 
> This driver is able to perform basic tx and rx, new features
> and improvements will be added as they are being developed and tested.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Applied, thanks.
