From: Stuart Peloquin <peloquin@MIT.EDU>
Subject: Re: Bug report for MV643XX driver
Date: Wed, 9 Aug 2006 13:30:47 -0400
Message-ID: <30B59DB8-9EEF-4BB2-A894-399662DFECA0@MIT.EDU>
References: <200608091047.28571.peloquin@mit.edu> <20060809162425.GA7464@xyzzy.farnsworth.org> <94266083-92C0-4771-8572-46C6B032E9EE@mit.edu> <20060809171839.GA12251@xyzzy.farnsworth.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mlachwani@mvista.com, netdev@vger.kernel.org, josejx@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from BISCAYNE-ONE-STATION.MIT.EDU ([18.7.7.80]:20191 "EHLO
	biscayne-one-station.mit.edu") by vger.kernel.org with ESMTP
	id S1751277AbWHIRbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 13:31:07 -0400
In-Reply-To: <20060809171839.GA12251@xyzzy.farnsworth.org>
To: "Dale Farnsworth" <dale@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Time is not an issue, I'm filing this after some drawn out testing.   
It won't be right away that I get it built under 3.3 either.

Thanks again,
-Stuart

On Aug 9, 2006, at 1:18 PM, Dale Farnsworth wrote:

> On Wed, Aug 09, 2006 at 12:53:27PM -0400, Stuart Peloquin wrote:
>> Hi Dale,
>>
>> Thank you for responding quickly.
>>
>> This is with gcc 4.1.1 and the config file has been added to the web
>> directory at http://web.mit.edu/peloquin/marvell/
>>
>> Please let me know if I can provide anything else.
>
> Can you test with an earlier version of the toolchain?  Maybe gcc-3.3?
>
> Just this week I rebuilt a kernel for one of my Debian x86 server  
> boxes
> with gcc-4.1, and the tulip driver died early on.  When I rebuilt with
> gcc-3.3, all was well.  I haven't had time to look for the details  
> yet.
>
> I'm not saying that gcc-4.1 is buggy, but this will help us narrow it
> down.
>
> BTW, I'm up against a deadline on another project, so I won't be able
> to devote a lot of time to this today.
>
> Thanks,
> -Dale

