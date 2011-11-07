From: David Miller <davem@davemloft.net>
Subject: Re: [net-ext PATCH] ixgbe: Fix compile for kernel without
 CONFIG_PCI_IOV defined
Date: Mon, 07 Nov 2011 13:23:40 -0500 (EST)
Message-ID: <20111107.132340.124929090969671336.davem@davemloft.net>
References: <20111107174417.8638.87569.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932491Ab1KGSXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 13:23:45 -0500
In-Reply-To: <20111107174417.8638.87569.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Mon, 07 Nov 2011 09:44:17 -0800

> Fix compiler errors and warnings with CONFIG_PCI_IOV defined and not
> defined.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>

It's "net-next" not "net-ext" :-)

Applied, thanks.
