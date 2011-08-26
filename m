From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] bna: unlock on error path in pnad_pci_probe()
Date: Fri, 26 Aug 2011 12:51:45 -0400 (EDT)
Message-ID: <20110826.125145.246690891101270580.davem@davemloft.net>
References: <20110824112922.GC5975@shale.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, ddutt@brocade.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334Ab1HZQwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:52:49 -0400
In-Reply-To: <20110824112922.GC5975@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 24 Aug 2011 14:29:22 +0300

> We introduced a new lock here, so there was error path which needs
> an unlock now.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
