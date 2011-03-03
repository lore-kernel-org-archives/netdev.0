From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] mii: Convert printks to netdev_info
Date: Thu, 03 Mar 2011 12:21:48 -0800 (PST)
Message-ID: <20110303.122148.245410126.davem@davemloft.net>
References: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
	<1b384ead46d062ba189b64649710a5625b7f6a2b.1299086044.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43010
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758748Ab1CCUVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:21:11 -0500
In-Reply-To: <1b384ead46d062ba189b64649710a5625b7f6a2b.1299086044.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed,  2 Mar 2011 09:18:11 -0800

> Add a bit more data to the output.
> Convert string speeds to integer.
> Object size reduced a tiny bit.
> 
> $ size drivers/net/mii.o*
>    text	   data	    bss	    dec	    hex	filename
>    4155	     56	   1000	   5211	   145b	drivers/net/mii.o.new
>    4184	     56	   1000	   5240	   1478	drivers/net/mii.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
