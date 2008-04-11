From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] net sockets: fix timewait namespace regression
Date: Thu, 10 Apr 2008 20:51:30 -0700 (PDT)
Message-ID: <20080410.205130.193698307.davem@davemloft.net>
References: <47FEB0E3.8080507@rtr.ca>
	<20080411.115907.116626245.yoshfuji@linux-ipv6.org>
	<47FED872.7010604@rtr.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, jesper.juhl@gmail.com, tilman@imap.cc,
	jeff@garzik.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xemul@openvz.org, torvalds@osdl.org,
	akpm@linux-foundation.org
To: lkml@rtr.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38720
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756970AbYDKDv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 23:51:29 -0400
In-Reply-To: <47FED872.7010604@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Lord <lkml@rtr.ca>
Date: Thu, 10 Apr 2008 23:18:10 -0400

> Works perfectly, thanks.  Looks obvious, too.
> Push it out to Linus now for 2.6.25.
> 
> Acked-by: Mark Lord <mlord@pobox.com>

Will do, thanks for testing.
