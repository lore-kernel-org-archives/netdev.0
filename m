From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tcp: connect() race with timewait reuse
Date: Thu, 03 Dec 2009 16:18:52 -0800 (PST)
Message-ID: <20091203.161852.171510808.davem@davemloft.net>
References: <20091202221552.GA17579@ioremap.net>
	<4B175E65.3070905@gmail.com>
	<4B177757.3010407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57092
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753570AbZLDASq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 19:18:46 -0500
In-Reply-To: <4B177757.3010407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Dec 2009 09:31:19 +0100

> [PATCH net-next-2.6] tcp: connect() race with timewait reuse

Applied.
