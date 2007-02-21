From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 1/5][SCTP]: Implement SCTP_FRAGMENT_INTERLEAVE socket
 option.
Date: Wed, 21 Feb 2007 00:20:44 -0800
Message-ID: <45DC00DC.8030504@us.ibm.com>
References: <1171683583.4568.10.camel@w-sridhar2.beaverton.ibm.com> <20070220.232136.112621337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:52324 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbXBUIUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 03:20:50 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1L8KnPK029462
	for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 03:20:49 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1L8KnP2299652
	for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 03:20:49 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1L8Km1m028426
	for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 03:20:49 -0500
In-Reply-To: <20070220.232136.112621337.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Fri, 16 Feb 2007 19:39:43 -0800
>
>   
>> [SCTP]: Implement SCTP_FRAGMENT_INTERLEAVE socket option.
>>     
>
> Sorry, these patches missed the merge window.
>
> Patches 4 and 5 are bug fixes, so I could apply just those if you
> want me to, just let me know and you don't need to resend them.
>   
Yes. please apply patches 4 & 5 for 2.6.21. I will resubmit the 
remaining when
2.6.22 merge window opens.

Thanks
Sridhar

