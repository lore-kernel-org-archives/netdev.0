From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] MAINTAINERS: STARFIRE/DURALAN update
Date: Fri, 26 Jun 2009 09:31:16 -0400
Message-ID: <4A44CDA4.5020904@garzik.org>
References: <1245946630.395.37.camel@Joe-Laptop.home>	 <4A43B060.30904@garzik.org> <1245951074.395.78.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ion Badulescu <ionut@badula.org>,
	NetDev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52756 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755893AbZFZNah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2009 09:30:37 -0400
In-Reply-To: <1245951074.395.78.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Thu, 2009-06-25 at 13:14 -0400, Jeff Garzik wrote:
>> Joe Perches wrote:
>>> Signed-off-by: Joe Perches <joe@perches.com>
>>>
>>> diff --git a/MAINTAINERS b/MAINTAINERS
>>> index fa2a16d..218126a 100644
>>> --- a/MAINTAINERS
>>> +++ b/MAINTAINERS
>>> @@ -5533,8 +5533,8 @@ F:	drivers/staging/
>>>  
>>>  STARFIRE/DURALAN NETWORK DRIVER
>>>  P:	Ion Badulescu
>>> -M:	ionut@cs.columbia.edu
>>> -S:	Maintained
>>> +M:	ionut@badula.org
>>> +S:	Odd Fixes
>>>  F:	drivers/net/starfire*
>>>  
>>>  STARMODE RADIO IP (STRIP) PROTOCOL DRIVER
>> This change needs a better explanation, and should be CC'd to netdev 
>> since it relates to network drivers.
> 
> His old email address is invalid.
> 
> I looked up his name in git log
> and found a single commit, emailed him
> and asked.
> 
> His new email is on the cc list.

Make sure to note this in the commit description...

Otherwise, there is no way for an outside reviewer to know why you 
changed "Maintained" to "Odd Fixes" rather than "Orphaned", etc.

	Jeff




