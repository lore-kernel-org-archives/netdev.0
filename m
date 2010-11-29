From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] xps: add __rcu annotations
Date: Mon, 29 Nov 2010 09:43:36 -0800 (PST)
Message-ID: <20101129.094336.183040331.davem@davemloft.net>
References: <1291016582.29196.136.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47299
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755490Ab0K2RnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 12:43:09 -0500
In-Reply-To: <1291016582.29196.136.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Nov 2010 08:43:02 +0100

> Avoid sparse warnings : add __rcu annotations and use
> rcu_dereference_protected() where necessary.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Tom Herbert <therbert@google.com>

Also applied, thanks Eric.
