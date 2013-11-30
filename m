From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 - it's dead jim
Date: Sat, 30 Nov 2013 23:18:01 +0100
Message-ID: <20131130221801.GA19790@electric-eye.fr.zoreil.com>
References: <20131124005022.GA6299@electric-eye.fr.zoreil.com>
 <5296C072.4070000@nurealm.net>
 <20131130203931.GA18929@electric-eye.fr.zoreil.com>
 <20131130.160629.2435326869658907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: james@nurealm.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42107 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab3K3WSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 17:18:08 -0500
Content-Disposition: inline
In-Reply-To: <20131130.160629.2435326869658907.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Francois should I apply this or are you just posting this to get
> testing feedback?

No, it's only debuging help and testing feedback straight from
format-patch.

If I don't send fixes as "[PATCH net x/y] r8169: ..." or features as
"[PATCH net-next 1/1] r8169: perform Tx completion before Rx processing"
during the net-next window in self-contained messages, you should
consider that nothing is expected to be applied and something is probably
going wrong.

-- 
Ueimor
