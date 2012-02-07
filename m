From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: enable TC35815 for MIPS again
Date: Tue, 07 Feb 2012 13:41:03 -0500 (EST)
Message-ID: <20120207.134103.197660314940081249.davem@davemloft.net>
References: <20120207.095103.46315035.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	ralf.roesch@rw-gmbh.de, stable@vger.kernel.org
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748Ab2BGSlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:41:13 -0500
In-Reply-To: <20120207.095103.46315035.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Tue, 07 Feb 2012 09:51:03 +0900 (JST)

> 8<----------------------------------------------------------------------
> From: Ralf Roesch <ralf.roesch@rw-gmbh.de>
> Date: Wed, 16 Nov 2011 09:33:50 +0100
> Subject: [PATCH] net: enable TC35815 for MIPS again
> 
> TX493[8,9] MIPS SoCs support 2 Ethernet channels of type TC35815
> which are connected to the internal PCI controller.
> And JMR3927 MIPS board has a TC35815 chip on board.
> These dependencies were lost on movement to drivers/net/ethernet/toshiba.
> 
> Signed-off-by: Ralf Roesch <ralf.roesch@rw-gmbh.de>
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> CC: stable@vger.kernel.org [3.2+]

Applied.
