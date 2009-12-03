From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers/net: Move && and || to end of
 previous line
Date: Thu, 03 Dec 2009 12:40:40 -0800 (PST)
Message-ID: <20091203.124040.251927671.davem@davemloft.net>
References: <1259528449.29779.194.camel@Joe-Laptop.home>
	<20091129.165557.84377714.davem@davemloft.net>
	<1259863101.22783.63.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56640
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753837AbZLCUke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:40:34 -0500
In-Reply-To: <1259863101.22783.63.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 03 Dec 2009 09:58:21 -0800

> Only files where David Miller is the primary git-signer.
> wireless, wimax, ixgbe, etc are not modified.
> 
> Compile tested x86 allyesconfig only
> Not all files compiled (not x86 compatible)
> 
> Added a few > 80 column lines, which I ignored.
> Existing checkpatch complaints ignored.
>     
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
