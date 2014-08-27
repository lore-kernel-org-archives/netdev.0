From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Driver for IBM System i/p VNIC protocol
Date: Wed, 27 Aug 2014 16:25:36 -0700 (PDT)
Message-ID: <20140827.162536.279933414728705938.davem@davemloft.net>
References: <53FB3FA8.3040304@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933980AbaH0XZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:25:36 -0400
In-Reply-To: <53FB3FA8.3040304@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santiago Leon <santil@linux.vnet.ibm.com>
Date: Mon, 25 Aug 2014 08:52:40 -0500

> This is a new device driver for a high performance SR-IOV assisted virtual
> network for IBM System p and IBM System i systems.  The SR-IOV VF will be
> attached to the VIOS partition and mapped to the Linux client via the
> hypervisor's VNIC protocol that this driver implements. 
> 
> This driver is able to perform basic tx and rx, new features and improvements
> will be added as they are being developed and tested. 
> 
> 
> Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>

Just a heads up, if nobody reviews this driver submission I am not
applying it.

Thanks.
