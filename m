From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Tue, 24 Oct 2006 19:25:48 -0700
Message-ID: <453ECB2C.3070202@candelatech.com>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:6377 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1422879AbWJYCY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 22:24:59 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061024050014.GC12506@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Mon, Oct 23, 2006 at 09:54:48PM -0700, Randy Dunlap wrote:
>   
>> Similarly, sysfs is desirable in some circumstances, but
>> not for blocks of binary data.
>>     
>
> sysfs specifically has APIs for binary data...
>   
 From reading the Documentation/filesystems/sysfs.txt, it seems like
it is not recommended that one use sysfs for anything other than
very simple (and single) attributes.

If you know of a piece of code that actually passes back a struct or
other binary blob of data, please point me to it so I can learn from it.

Thanks,
Ben

> 	Jeff
>
>
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


