From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Fri, 08 Nov 2013 12:45:09 -0500 (EST)
Message-ID: <20131108.124509.1262461348696784377.davem@davemloft.net>
References: <20131107112549.GP31491@secunet.com>
	<527B8DC5.6080702@6wind.com>
	<20131108110101.GR31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe.gouault@6wind.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, saurabh.mohan@vyatta.com,
	sergei.shtylyov@cogentembedded.com, eric.dumazet@gmail.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757407Ab3KHRpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 12:45:14 -0500
In-Reply-To: <20131108110101.GR31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 8 Nov 2013 12:01:01 +0100

> I was not on Cc and it looks like I've overlooked this on the list.
> The vti interfaces are pure IPsec interfaces, so perhaps we should
> add them to the IPsec section in the maintainers file (maybe together
> with the main IPsec protocols esp, ah and ipcomp, which are also not
> listed there).
> 
> David, would you agree with such a patch?

Yes.
