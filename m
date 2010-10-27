From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 15:00:23 -0400
Message-ID: <4CC876C7.6010803@windriver.com>
References: <AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>	<20101027.105047.183059900.davem@davemloft.net>	<AANLkTi=jDDDk15KDhsC=qTnmgU5Urhc9LTrROkFOsY_Q@mail.gmail.com> <20101027.113537.15227235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38533 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755095Ab0J0TG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:06:29 -0400
In-Reply-To: <20101027.113537.15227235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-10-27 02:35 PM, David Miller wrote:
> From: Paul Gortmaker<paul.gortmaker@windriver.com>
> Date: Wed, 27 Oct 2010 14:27:13 -0400
> 
>> I've got some patches from Al that I'm pre-reviewing/testing
>> before spamming everyone with them (will send within 24h, if
>> that is OK).   Anyway, in the above, does it make sense to
>> check for the overflow incrementally, i.e. something like this?
> 
> Can you please not work on this in private?  That's the only reason
> we have duplicated work here.

Sorry -- my intent was to not waste people's time with stuff
that might have obvious issues.  I'll send what I have now
and we can go from there.

P.


