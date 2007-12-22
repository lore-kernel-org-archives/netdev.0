From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] MAINTAINERS: remove Adam Fritzler, update his email address
 in other sources
Date: Sat, 22 Dec 2007 03:53:03 -0500
Message-ID: <476CD06F.3090402@pobox.com>
References: <1197951126.4891.13.camel@localhost>	<20071217202800.1c898441.akpm@linux-foundation.org>	<1197953283.4891.24.camel@localhost> <20071222004448.36c95d98.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Adam Fritzler <mid@zigamorph.net>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Mike Phillips <mikep@linuxtr.net>,
	Philip Blundell <philb@gnu.org>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34118 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbXLVIxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Dec 2007 03:53:14 -0500
In-Reply-To: <20071222004448.36c95d98.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Mon, 17 Dec 2007 20:48:03 -0800 Joe Perches <joe@perches.com> wrote:
> 
>> Back to Adam Fritzler...
>>
>> ...
>>
>> diff --git a/CREDITS b/CREDITS
>> index ee909f2..449ec7f 100644
>> --- a/CREDITS
>> +++ b/CREDITS
>> @@ -1124,6 +1124,9 @@ S: 1150 Ringwood Court
>>  S: San Jose, California 95131
>>  S: USA
>>  
>> +N: Adam Fritzler
>> +E: mid@zigamorph.net
>> +
>>  N: Fernando Fuganti
>>  E: fuganti@conectiva.com.br
>>  E: fuganti@netbank.com.br
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 9507b42..690f172 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -3758,13 +3758,6 @@ W:	http://www.kernel.org/pub/linux/kernel/people/bunk/trivial/
>>  T:	git kernel.org:/pub/scm/linux/kernel/git/bunk/trivial.git
>>  S:	Maintained
>>  
>> -TMS380 TOKEN-RING NETWORK DRIVER
>> -P:	Adam Fritzler
>> -M:	mid@auk.cx
>> -L:	linux-tr@linuxtr.net
>> -W:	http://www.auk.cx/tms380tr/
>> -S:	Maintained
> 
> What was the rationale for removing Adam from MAINTAINERS?
> 
> That should have been in the non-existent changelog.  Please always reissue
> a complete changelog when resending any patch.
> 
> hm, linux-tr.net seems to be defunct.  So I guess that orphaning TMS380 is
> appropriate, if Adam has left us.  Has he?

I don't know that specific answer, but in terms of general policy...

I wouldn't apply this patch until they have been in 
Documentation/people-removal-schedule.txt for a year or so ;-)  More 
seriously, its not like MAINTAINERS is a mission critical correctness 
target -- so I think we can do a better job than just yanking people 
from the file like this.

	Jeff



