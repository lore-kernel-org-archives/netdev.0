From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 11/14] NET: MIPS: lantiq: convert etop driver to
 clkdev api
Date: Fri, 24 Feb 2012 03:28:12 -0500 (EST)
Message-ID: <20120224.032812.10813781440356110.davem@davemloft.net>
References: <1330012993-13510-1-git-send-email-blogic@openwrt.org>
	<1330012993-13510-11-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: blogic@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625Ab2BXI2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 03:28:23 -0500
In-Reply-To: <1330012993-13510-11-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <blogic@openwrt.org>
Date: Thu, 23 Feb 2012 17:03:10 +0100

> Update from old pmu_{dis,en}able() to ckldev api.
> 
> Signed-off-by: John Crispin <blogic@openwrt.org>

Come on guys, don't do crap like this.

When you have a 14 patch series, and I only see one or two of them
I have no idea what in the world you want me to do with these patches.

Are they dependent upon the previous patches that weren't sent to me?

Are they not and I can just apply them as-is?

Could I apply them as-is, but you want them to go via the MIPS tree
for some reason and just want my ACK?

Nobody knows because you didn't bother to say one way or another
and that is extremely irritating because as a result I have to
ask you all of these stupid questions and write this rediculious
email.

I'm just ignoring every single one of these MIPS patches, sorry.
