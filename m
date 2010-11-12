From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 14:46:02 -0800 (PST)
Message-ID: <20101112.144602.232909145.davem@davemloft.net>
References: <20101112201850.GA5625@core2.telecom.by>
	<20101112.123738.179940542.davem@davemloft.net>
	<20101112224026.GA21134@core2.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932147Ab0KLWph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 17:45:37 -0500
In-Reply-To: <20101112224026.GA21134@core2.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 13 Nov 2010 00:40:27 +0200

> I think we should not expose kernel pointers in future interfaces,
> but leave existing ones alone.

That seems like the most reasonable and pragmatic position I've seen
thus far :-)
