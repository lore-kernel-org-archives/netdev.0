From: Ben Greear <greearb@candelatech.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 16:29:25 -0700
Message-ID: <4AD65ED5.4030801@candelatech.com>
References: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>	<20091014203640.GB32317@ioremap.net>	<4AD64251.50903@candelatech.com> <20091014.144923.112167161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, deri@ntop.org, shemminger@vyatta.com,
	brad.doctor@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59700 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300AbZJNXae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 19:30:34 -0400
In-Reply-To: <20091014.144923.112167161.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2009 02:49 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Wed, 14 Oct 2009 14:27:45 -0700
>
>> Maybe something similar to the attached patch?
>
> This is not something I'm interested in applying.
>
> It makes implementing proprietary complete networking stacks
> for Linux way too easy.
 >
> Instead I'd rather have a GPL exported function that allows indication
> of consumption somehow.

This would mean one hard-coded hook for every application that wanted
this feature, or is there some way to have a gpl_ptype_all?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

