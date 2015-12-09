From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] sh_eth: optimize MDIO code
Date: Tue, 08 Dec 2015 21:56:08 -0500 (EST)
Message-ID: <20151208.215608.42383332595350416.davem@davemloft.net>
References: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbbLIC4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 21:56:10 -0500
In-Reply-To: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 08 Dec 2015 00:39:03 +0300

>    Here's a set of 3 patches against DaveM's 'net-next.git' repo
> which gets rid of ~35 LoCs in the MDIO bitbang methods.

Series applied, thanks!
