From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] soreuseport: TCP/IPv4 implementation
Date: Wed, 16 Jan 2013 16:10:35 -0500 (EST)
Message-ID: <20130116.161035.2165535554573680681.davem@davemloft.net>
References: <alpine.DEB.2.00.1301141140330.3472@pokey.mtv.corp.google.com>
	<alpine.DEB.2.00.1301161259370.1764@cleese>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989Ab3APVKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:10:37 -0500
In-Reply-To: <alpine.DEB.2.00.1301161259370.1764@cleese>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Wed, 16 Jan 2013 13:09:10 -0800 (PST)

> 
> +/* The port cannot be reused if the older socket is in LISTEN state
> or if
> + * either the old or new one does not allow reuse
> + */

Please post patches without them being destroyed by your mailer.
