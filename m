From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] MAINTAINERS: add myself as Renesas Ethernet drivers
 reviewer
Date: Sat, 5 Dec 2015 03:57:36 +0300
Message-ID: <56623680.4050808@cogentembedded.com>
References: <1846877.jRW8849mPU@wasted.cogentembedded.com>
 <1449276063.8611.25.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1449276063.8611.25.camel@perches.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/05/2015 03:41 AM, Joe Perches wrote:

>> liAdd myself as  a reviewer for the Renesas Ethernet drivers --
>> hopefully I
>> won't miss the buggy  patches anymore. :-)
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>> The patch is against DaveM's 'net.git' repo.
>>
>>   MAINTAINERS |    8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> Index: net/MAINTAINERS
>> ===================================================================
>> --- net.orig/MAINTAINERS
>> +++ net/MAINTAINERS
>> @@ -8929,6 +8929,14 @@ F:	drivers/rpmsg/
>>   F:	Documentation/rpmsg.txt
>>   F:	include/linux/rpmsg.h
>>
>> +RENESAS ETHERNET DRIVERS
>> +R:	Sergei Shtylyov <serge.shtylyov@cogentembedded.com>
>> +L:	netdev@vger.kernel.orgc
>> +L:	linux-sh@vger.kernel.org
>> +S:	Maintained
>> +F:	drivers/net/ethernet/renesas/
>> +F:	include/linux/sh_eth.h

> Hello Sergei
>
> Typically a reviewer isn't a maintainer.

    Yeah, I didn't take courage to become a real maintainer, being always 
short of time... But I was annoyed by dubious quality patches being merged 
recently.

> Does anyone actually maintain this?

    Only DaveM.

> I suggest you mark this "S: Odd fixes" or
> remove the "S:" line altogether unless you
> really want to become the maintainer.

    OK, will remove, if that's OK.

PS: Since you seem to be get_maintainers.pl maintainer, I (and not only I)
would like to propose a switch to suppress the committers/authors/etc. It's 
generally annoying and unhelpful to have the bunch of people listed, none of 
which usually are a good addressees for the patches...

MBR, Sergei

