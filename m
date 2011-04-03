From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] net: filter: Just In Time compiler
Date: Sat, 02 Apr 2011 22:43:44 -0700 (PDT)
Message-ID: <20110402.224344.191403947.davem@davemloft.net>
References: <1301783301.2837.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@infradead.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52490
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751470Ab1DCFoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 01:44:21 -0400
In-Reply-To: <1301783301.2837.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 03 Apr 2011 00:28:21 +0200

> In order to speedup packet filtering, here is an implementation of a JIT
> compiler for x86_64

Looks great.  Of course, everything should sit under arch/${ARCH}/ in the
end, but this is an excellent proof of concept!
