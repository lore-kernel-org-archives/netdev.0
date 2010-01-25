From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Update documentation for better built-in help with
 params
Date: Mon, 25 Jan 2010 12:28:15 -0500
Message-ID: <4B5DD4AF.8050800@hp.com>
References: <201001221901.o0MJ1oLk016090@wind.enjellic.com>	<4B5A0991.9080701@hp.com> <20100122.183223.197255353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: greg@enjellic.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:6013 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab0AYR2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 12:28:24 -0500
In-Reply-To: <20100122.183223.197255353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Fri, 22 Jan 2010 15:24:49 -0500
> 
>> Update IPv6 documentation to describe how to set parameters when it's
>> built-into the kernel.  Reported by <greg@enjellic.com>.
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> So are you going to also add a mention of this fact to every single
> place in the documentation that talks about some arbitrary module
> option?
> 
> That doesn't make any sense, and neither does this patch.
> 
> It's better to make it more apparent that module options can
> be set on the kernel command line when something is compiled
> statically into the kernel.
> 
> That way it only needs to be explained in one place, not in
> several.

I guess Documentation/kernel-parameters.txt is where such things
live, can I send you a patch for that or does it need to go
through someone else?

-Brian
