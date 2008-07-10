From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/4] MIB: add struct net to UDP accounting macros
Date: Thu, 10 Jul 2008 13:04:56 +0200
Message-ID: <20080710110456.GQ20815@postel.suug.ch>
References: <486E1074.7040702@openvz.org> <20080705.212138.06508305.davem@davemloft.net> <4871D027.4070504@openvz.org> <20080707.014726.265626342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@openvz.org, netdev@vger.kernel.org, den@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39360 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927AbYGJLEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 07:04:36 -0400
Content-Disposition: inline
In-Reply-To: <20080707.014726.265626342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> 2008-07-07 01:47
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Mon, 07 Jul 2008 12:13:27 +0400
> 
> > BTW, are there some plans about implementing some netlink-based fetcher
> > of this statistics? If so, then I think it's worth making this engine
> > namespaces aware from the very beginning.
> 
> I'm not aware of any, or whether that would make any sense.

There have been plans but none was brave enough so far.
