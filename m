From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sh_eth changes for net-next
Date: Wed, 04 Mar 2015 15:41:17 -0500 (EST)
Message-ID: <20150304.154117.1633794444860073923.davem@davemloft.net>
References: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	nobuhiro.iwamatsu.yj@renesas.com, mitsuhiro.kimura.kc@renesas.com,
	ykaneko0929@gmail.com, yoshihiro.shimoda.uh@renesas.com
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbCDUlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:41:20 -0500
In-Reply-To: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Thu, 26 Feb 2015 20:31:05 +0000

> Some minor new features and fixes.
> 
> These depend in part on the series I sent earlier for net, specifically
> "sh_eth: WARN on access to a register not implemented in a particular
> chip" depends on "sh_eth: Fix RX recovery on R-Car in case of RX ring
> underrun".

Series applied, thanks Ben.
