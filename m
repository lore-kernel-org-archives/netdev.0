From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Don't return NULL from get_phy_device() anymore
Date: Mon, 16 May 2016 13:53:49 -0400 (EDT)
Message-ID: <20160516.135349.1027929193904713083.davem@davemloft.net>
References: <7078673.lTHka36u4G@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbcEPRxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:53:51 -0400
In-Reply-To: <7078673.lTHka36u4G@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 14 May 2016 02:05:17 +0300

> Hello.
> 
>    Here's the set of 2 patches against DaveM's 'net-next.git' repo. We save
> several LoCs on the unneeded local variables....
> 
> [1/2] lxt: simplify lxt97[01]_config_intr()
> [2/2] lxt: simplify lxt970_config_init()

I'm pretty sure that Subject isn't accurate so I didn't include it in the
merge commit for this series :)

Series applied, thanks.
