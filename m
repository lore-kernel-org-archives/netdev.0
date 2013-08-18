From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Sun, 18 Aug 2013 09:59:27 -0700
Message-ID: <5210FD6F.5090003@fatooh.org>
References: <521061B4.1030508@fatooh.org> <1376839467.21329.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:45377 "EHLO
	juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab3HRQ72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 12:59:28 -0400
In-Reply-To: <1376839467.21329.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-08-18 08:24, Eric Dumazet wrote:
> This looks like the bug we had to fix recently : 
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=356d7d88e088687b6578ca64601b0a2c9d145296
> 
> Could you try latest net tree ?

Thanks, I will do so, hopefully this evening (busy today).

-Corey
