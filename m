From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net/sock.h: add missing kernel-doc notation
Date: Tue, 10 Aug 2010 00:09:51 -0700 (PDT)
Message-ID: <20100810.000951.28795076.davem@davemloft.net>
References: <20100809164107.a992561a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602Ab0HJHJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 03:09:31 -0400
In-Reply-To: <20100809164107.a992561a.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 9 Aug 2010 16:41:07 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Add missing kernel-doc notation to struct sock:
> 
> Warning(include/net/sock.h:324): No description found for parameter 'sk_peer_pid'
> Warning(include/net/sock.h:324): No description found for parameter 'sk_peer_cred'
> Warning(include/net/sock.h:324): No description found for parameter 'sk_classid'
> Warning(include/net/sock.h:324): Excess struct/union/enum/typedef member 'sk_peercred' description in 'sock'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied.
