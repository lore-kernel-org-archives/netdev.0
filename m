From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] MIB: add struct net to UDP accounting macros
Date: Mon, 07 Jul 2008 01:47:26 -0700 (PDT)
Message-ID: <20080707.014726.265626342.davem@davemloft.net>
References: <486E1074.7040702@openvz.org>
	<20080705.212138.06508305.davem@davemloft.net>
	<4871D027.4070504@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, tgraf@suug.ch
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751319AbYGGIr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 04:47:27 -0400
In-Reply-To: <4871D027.4070504@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 07 Jul 2008 12:13:27 +0400

> BTW, are there some plans about implementing some netlink-based fetcher
> of this statistics? If so, then I think it's worth making this engine
> namespaces aware from the very beginning.

I'm not aware of any, or whether that would make any sense.

Thomas?
