From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 18:30:34 +0200
Message-ID: <1342629034.2626.3109.camel@edumazet-glaptop>
References: <1342620841.2626.2786.camel@edumazet-glaptop>
	 <1342621670.2626.2818.camel@edumazet-glaptop>
	 <20120718.091647.2208692760443941786.davem@davemloft.net>
	 <20120718.091928.492512069081953171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, andrewmcgr@gmail.com,
	dave.taht@gmail.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:60943 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab2GRQaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:30:39 -0400
Received: by yenl2 with SMTP id l2so1757477yen.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 09:30:39 -0700 (PDT)
In-Reply-To: <20120718.091928.492512069081953171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 09:19 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 18 Jul 2012 09:16:47 -0700 (PDT)
> 
> > 
> > Just to clarify, I made sure to use this version.
> 
> Did you actually try to compile this?
> 
> net/ipv6/addrconf.c already has a function named ipv6_addr_hash()
> and you didn't remove it in your patch.


Oops, sorry, will send a v4 then.
