From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 0/6] pasemi_mac updates for 2.6.26
Date: Tue, 26 Feb 2008 13:21:00 -0500
Message-ID: <47C4588C.5060904@pobox.com>
References: <20080221025753.903665000@lixom.net> <18371.57542.77446.443231@cargo.ozlabs.ibm.com> <20080226141624.GB22572@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	pasemi-linux@ozlabs.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56904 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762623AbYBZSVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 13:21:05 -0500
In-Reply-To: <20080226141624.GB22572@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson wrote:
> On Tue, Feb 26, 2008 at 08:49:58PM +1100, Paul Mackerras wrote:
>> Olof Johansson writes:
>>
>>> Here's a set of updates for pasemi_mac for 2.6.26. Some of them touch
>>> the dma_lib in the platform code as well, but it's easier if it's all
>>> merged through netdev to avoid dependencies.
>>>
>>> Major highlights are jumbo frame support and ethtool basics, the rest
>>> is mostly minor plumbing around it.
>> What route do you think these should take upstream?  I'm happy to take
>> them if Jeff is OK with that.
> 
> I've sent them through Jeff in the past, that's been convenient when
> there's been churn in the network APIs. I'm not sure if there's much of
> that for .26 though.
> 
> If Jeff prefers to ACK, I'll just add it to my git and ask you to pull
> that. But I was originally planning to just feed it through him.
> 
> (Note: I'll repost the patch set later today or tomorrow with a couple
> of tweaks).

Not much networking churn for 2.6.26, and IMO this patchset have 
above-average ppc changes/dependencies, so....   ACK


