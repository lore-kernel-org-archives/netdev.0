From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: use pci_vfs_assigned()/pci_num_vf()
 instead of be_find_vfs()
Date: Wed, 19 Jun 2013 21:23:46 -0700 (PDT)
Message-ID: <20130619.212346.1740668768856201859.davem@davemloft.net>
References: <1371205491-11768-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab3FTEXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 00:23:47 -0400
In-Reply-To: <1371205491-11768-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 14 Jun 2013 15:54:51 +0530

> be_find_vfs() is no longer needed as the common PCI calls provide the same
> functionality.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
