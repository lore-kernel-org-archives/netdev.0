From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Fix filtering related to flushing IP addresses.
Date: Fri, 20 Aug 2010 11:55:32 -0700
Message-ID: <4C6ECFA4.8040104@candelatech.com>
References: <1281978008-6383-1-git-send-email-greearb@candelatech.com>	<4C6EC047.1030308@candelatech.com> <20100820114915.6d46cf8b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53941 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980Ab0HTSzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 14:55:35 -0400
In-Reply-To: <20100820114915.6d46cf8b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/20/2010 11:49 AM, Stephen Hemminger wrote:
> On Fri, 20 Aug 2010 10:49:59 -0700
> Ben Greear<greearb@candelatech.com>  wrote:
>
>> On 08/16/2010 10:00 AM, Ben Greear wrote:
>>> The old 'ip addr flush' logic had several flaws:
>>
>> Stephen, any chance this can be accepted upstream?
>>
>> Thanks,
>> Ben
>
> Since it had gone for a couple versions, was waiting for the
> dust to settle for a week or so.

Ok, no problem...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

