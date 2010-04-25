From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Sun, 25 Apr 2010 15:08:50 -0700 (PDT)
Message-ID: <20100425.150850.82706768.davem@davemloft.net>
References: <20100425155600.GA13319@ioremap.net>
	<1272212460.2069.9.camel@edumazet-laptop>
	<20100425163543.GA11831@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, zbr@ioremap.net, greearb@candelatech.com,
	gasparch@gmail.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44165
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752138Ab0DYWIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 18:08:45 -0400
In-Reply-To: <20100425163543.GA11831@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 25 Apr 2010 19:35:43 +0300

>> 
>> [PATCH] ipv6: Fix inet6_csk_bind_conflict()
 ...
> 
> works for me
> Tested-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks everyone.
