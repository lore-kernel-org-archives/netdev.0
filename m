From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] mii: Convert printks to netdev_info
Date: Thu, 03 Mar 2011 12:32:25 -0800 (PST)
Message-ID: <20110303.123225.242141985.davem@davemloft.net>
References: <1b384ead46d062ba189b64649710a5625b7f6a2b.1299086044.git.joe@perches.com>
	<20110303.122148.245410126.davem@davemloft.net>
	<1299184181.4338.152.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36130
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752372Ab1CCUbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:31:47 -0500
In-Reply-To: <1299184181.4338.152.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 03 Mar 2011 12:29:41 -0800

> On Thu, 2011-03-03 at 12:21 -0800, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> > Add a bit more data to the output.
>> > Convert string speeds to integer.
>> > Object size reduced a tiny bit.
>> > $ size drivers/net/mii.o*
>> >    text	   data	    bss	    dec	    hex	filename
>> >    4155	     56	   1000	   5211	   145b	drivers/net/mii.o.new
>> >    4184	     56	   1000	   5240	   1478	drivers/net/mii.o.old
>> > Signed-off-by: Joe Perches <joe@perches.com>
>> Applied.
> 
> David, please don't push this yet.

Reverted.

> This change is stuffed up somehow, it's
> a reversion of the tun.c change.

Oops.

> Let me send you a new/correct patch right now.

Ok.
