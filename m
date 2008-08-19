From: Jean-Christophe DUBOIS <jcd@tribudubois.net>
Subject: Re: network card with inline crypto =?UTF-8?Q?engine=3F?=
Date: Tue, 19 Aug 2008 16:38:56 +0200
Message-ID: <335b1a8e57d24608fae99045a49cb70b@91.121.53.53>
References: <804fd2027cd558087a3db013b9ec80af@91.121.53.53> <20080819.015036.223405950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns27106.ovh.net ([91.121.84.22]:57524 "EHLO ns1.w4a.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751085AbYHSOjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 10:39:00 -0400
In-Reply-To: <20080819.015036.223405950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks Dave,

I guess you are refering to this proposal:

http://oss.sgi.com/archives/netdev/2005-01/msg00347.html

And nothing is in the plan at the moment?

JC

On Tue, 19 Aug 2008 01:50:36 -0700 (PDT), David Miller
<davem@davemloft.net> wrote:
> From: Jean-Christophe DUBOIS <jcd@tribudubois.net>
> Date: Tue, 19 Aug 2008 10:16:56 +0200
> 
>> Is there in the linux tree a "reference" implementation for a network
> card
>> with inline crypto engine that would be used for IPSEC among other
> things.
> 
> Not really.
> 
> Once there was an attempt to support the crypto offload some
> older 3com networking cards have, but that never went anywhere
> and the hooks that were added by that code to the IPSEC stack
> were never in a clean and usable state so never were merged.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

