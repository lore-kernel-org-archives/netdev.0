From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 11/14] NET: MIPS: lantiq: convert etop driver to
 clkdev api
Date: Fri, 24 Feb 2012 03:53:52 -0500 (EST)
Message-ID: <20120224.035352.619003522379818254.davem@davemloft.net>
References: <1330012993-13510-11-git-send-email-blogic@openwrt.org>
	<20120224.032812.10813781440356110.davem@davemloft.net>
	<4F474D02.1040306@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: blogic@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab2BXIyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 03:54:01 -0500
In-Reply-To: <4F474D02.1040306@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <blogic@openwrt.org>
Date: Fri, 24 Feb 2012 09:40:34 +0100

> One question if I may ask
> * do you want to be CC'ed for a full series even if only 1 patch relates
> to netdev or should I simply think more about the commit message so it
> is apparent what i expect ?

Only post the networking patches and mention the situation at hand
in this kind of case.
