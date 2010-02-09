From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH iproute2] ip: print "temporary" for IPv6 temp addresses
Date: Tue, 09 Feb 2010 09:49:46 -0500
Message-ID: <4B71760A.6060607@hp.com>
References: <4AAEAF37.7020305@hp.com>	<4B18144E.7020907@hp.com>	<20091203122045.2f6e7cd7@nehalam>	<4B18203D.8070309@hp.com> <20091226111759.22a9ebe1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:29142 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270Ab0BIOuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 09:50:00 -0500
In-Reply-To: <20091226111759.22a9ebe1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>>>> Brian Haley wrote:
>>>>> IPv6 addresses that have IFA_F_SECONDARY set are actually temporary addresses,
>>>>> hence the IFA_F_TEMPORARY equivalent.  Change the output in this case and
>>>>> allow filtering on the word "temporary".
>>>> I didn't see this in your current git tree, just pinging you about it.  This
>>>> would apply on top of my dad_failed patch.
>>>>
>>> I'll put it as well, why did patchwork not see it?
>> I can only assume it was my subject line?
>>
>> Let me know if I need to re-send as it was based on the other one.
>>
>> -Brian
> 
> This in for 2.6.33 (next version)

Hi Stephen,

Sorry to bug you again, but I still don't see this patch in your
iproute2 git tree, although I see things done after it.  Do I have
to wait until you tag a v2.6.33?

Thanks,

-Brian
