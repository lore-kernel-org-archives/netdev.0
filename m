From: David Miller <davem@davemloft.net>
Subject: Re: net 01/02: allow to propagate errors through
 ->ndo_hard_start_xmit()
Date: Fri, 13 Nov 2009 14:10:25 -0800 (PST)
Message-ID: <20091113.141025.261731690.davem@davemloft.net>
References: <4AF99156.9050301@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755123AbZKMWKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 17:10:09 -0500
In-Reply-To: <4AF99156.9050301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 10 Nov 2009 17:14:14 +0100

> The following two patches add support for error propagation
> through ->ndo_hard_start_xmit() and use it to propagate qdisc
> submission state through VLAN and macvlan devices.

Both applied to net-next-2.6, thanks.
