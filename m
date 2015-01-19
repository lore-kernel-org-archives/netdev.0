From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] sh_eth fixes
Date: Mon, 19 Jan 2015 15:38:06 -0500 (EST)
Message-ID: <20150119.153806.1641175874244852952.davem@davemloft.net>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	nobuhiro.iwamatsu.yj@renesas.com, mitsuhiro.kimura.kc@renesas.com,
	hisashi.nakamura.ak@renesas.com, ykaneko0929@gmail.com
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbbASUiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:38:09 -0500
In-Reply-To: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Fri, 16 Jan 2015 17:49:52 +0000

> I'm currently looking at Ethernet support on the R-Car H2 chip,
> reviewing and testing the sh_eth driver.  Here are fixes for two fairly
> obvious bugs in the driver; I will probably have some more later.
> 
> These are not tested on any of the other supported chips.

Series applied, thanks Ben.
