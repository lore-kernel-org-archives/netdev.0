From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [PATCH 1/2][RESEND] ehea: error handling improvement
Date: Fri, 23 Apr 2010 10:22:33 +0200
Message-ID: <4BD158C9.90807@de.ibm.com>
References: <201004211110.55986.tklein@de.ibm.com> <20100421.223620.257172362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tklein@de.ibm.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, themann@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:33076 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab0DWIWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 04:22:35 -0400
In-Reply-To: <20100421.223620.257172362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2010 07:36 AM, David Miller wrote:
> From: Thomas Klein<tklein@de.ibm.com>
> Date: Wed, 21 Apr 2010 11:10:55 +0200
>
>> Reset a port's resources only if they're actually in an error state
>>
>> Signed-off-by: Thomas Klein<tklein@de.ibm.com>
>> ---
>>
>> Patch created against net-2.6
>
> I thought you were sorry for wasting my time and that you were going
> to follow the directions I gave you last time, and I quote:
>
> --------------------
> 3) These are not appropriate for net-2.6 as we are deep in
>     the -rcX series at this point and only the most diabolical
>     bug fixes are appropriate.  Therefore, please generate these
>     against net-next-2.6, thanks.
> --------------------
>
> And here you are generating your patches against net-2.6.  Heck, you
> even feel it's worth mentioning explicitly.

Guilty! Allows no excuse. Screwed it. Deeply sorry.

>
> Lucky for you the patches happen to apply cleanly to net-next-2.6 so
> I've put them there.

Thanks!
Thomas

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
