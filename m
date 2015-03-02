From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sh_eth changes for net-next
Date: Mon, 02 Mar 2015 15:34:24 -0500 (EST)
Message-ID: <20150302.153424.1752879269616212723.davem@davemloft.net>
References: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	nobuhiro.iwamatsu.yj@renesas.com, mitsuhiro.kimura.kc@renesas.com,
	ykaneko0929@gmail.com, yoshihiro.shimoda.uh@renesas.com
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753447AbbCBUe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:34:27 -0500
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

Ben, in case it isn't clear, I'm waiting for you to respin your sh_eth
bug fix patch series for 'net' based upon the feedback you were given.

The longer it takes for you to resubmit a new version of that, the longer
this patch series is going to rot in patchwork and I really hate that.
