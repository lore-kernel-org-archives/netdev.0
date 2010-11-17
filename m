From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] ipv6: AF_INET6 link address family
Date: Wed, 17 Nov 2010 11:30:54 -0800 (PST)
Message-ID: <20101117.113054.242136515.davem@davemloft.net>
References: <20101116143357.GD26669@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935370Ab0KQTaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 14:30:30 -0500
In-Reply-To: <20101116143357.GD26669@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Tue, 16 Nov 2010 09:33:57 -0500

> IPv6 already exposes some address family data via netlink in the
> IFLA_PROTINFO attribute if RTM_GETLINK request is sent with the
> address family set to AF_INET6. We take over this format and
> reuse all the code.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
