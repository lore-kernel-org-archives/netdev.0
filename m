From: David Miller <davem@davemloft.net>
Subject: Re: niu: ethtool -s support?
Date: Tue, 25 Nov 2008 13:31:24 -0800 (PST)
Message-ID: <20081125.133124.74121407.davem@davemloft.net>
References: <20081125133530.GA1633@schweikert.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david@schweikert.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbYKYVbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 16:31:25 -0500
In-Reply-To: <20081125133530.GA1633@schweikert.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Schweikert <david@schweikert.ch>
Date: Tue, 25 Nov 2008 14:35:30 +0100

> Hi,
> 
> It is apparently not possible to set the link parameters on a niu
> interface (speed, duplex mode, auto-negotiation) with ethtool.
> Is support for it planned?

Yes, at some point, although that work is pretty low priority
to be honest.
