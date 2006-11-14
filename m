From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel
 found
Date: Tue, 14 Nov 2006 15:16:36 +0200
Message-ID: <4559C1B4.4010609@tcs.hut.fi>
References: <4549EFA7.50004@tcs.hut.fi>	<20061102.231810.119656005.yoshfuji@linux-ipv6.org>	<4549FF0F.6020705@tcs.hut.fi> <20061113.165716.26277561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:56013 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S933367AbWKNNQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 08:16:37 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061113.165716.26277561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ville Nuorvala <vnuorval@tcs.hut.fi>
> Date: Thu, 02 Nov 2006 16:22:07 +0200
> 
>> Ok, I'll resubmit a patch doesn't send an ICMPv6 error message.
> 
> Is this coming soon?  I'd like to integrate this patch set into
> net-2.6.20 if I can.

No, it was a false alarm as Herbert's patch already addressed the problem.

Regards,
Ville
