From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 34/53] netns xfrm: lookup in netns
Date: Tue, 25 Nov 2008 17:35:25 -0800 (PST)
Message-ID: <20081125.173525.138081153.davem@davemloft.net>
References: <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-33-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-34-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37265
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752222AbYKZBfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:35:25 -0500
In-Reply-To: <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:27:06 +0300

> Pass netns to xfrm_lookup()/__xfrm_lookup(). For that pass netns
> to flow_cache_lookup() and resolver callback.
> 
> Take it from socket or netdevice. Stub DECnet to init_net.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
