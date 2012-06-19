From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] TCP: Support configurable delayed-ack parameters.
Date: Tue, 19 Jun 2012 14:27:09 -0700
Message-ID: <4FE0EEAD.7050601@candelatech.com>
References: <1340067163-29329-1-git-send-email-greearb@candelatech.com> <1340082688.7491.2299.camel@edumazet-glaptop> <4FE0A4CF.6000906@candelatech.com> <20120619.142158.2026176205742396086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, dbaluta@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51148 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab2FSV15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:27:57 -0400
In-Reply-To: <20120619.142158.2026176205742396086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2012 02:21 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Tue, 19 Jun 2012 09:11:59 -0700
>
>> Dave..any opinion on this?  I'll be happy to get rid of the
>> multiply caching if it's agreed that it should not be there.
>
> I disagree fundamentally with the feature.
>
> I can't believe for one minute that we can't do ACK stretching
> dynamically using reasonable heuristics.
>
> And, as Stephen said, we already have too many damn knobs.

Ok...I'll let someone else take a stab at that.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
