From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK]: Add rtnl_put_cacheinfo() to unify some code
Date: Mon, 27 Nov 2006 09:27:21 -0800 (PST)
Message-ID: <20061127.092721.11607229.davem@davemloft.net>
References: <20061127090357.GV8693@postel.suug.ch>
	<20061127091320.GW8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39570
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758460AbWK0R1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 12:27:19 -0500
To: tgraf@suug.ch
In-Reply-To: <20061127091320.GW8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 27 Nov 2006 10:13:20 +0100

> Resend: Need to export rtnl_put_cacheinfo() for IPv6
> 
> IPv4, IPv6, and DECNet all use struct rta_cacheinfo in a similiar
> way, therefore rtnl_put_cacheinfo() is added to reuse code.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Also applied, thanks Thomas.
