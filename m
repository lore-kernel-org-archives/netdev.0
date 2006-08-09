From: Stuart Peloquin <peloquin@MIT.EDU>
Subject: Re: Bug report for MV643XX driver
Date: Wed, 9 Aug 2006 12:53:27 -0400
Message-ID: <94266083-92C0-4771-8572-46C6B032E9EE@mit.edu>
References: <200608091047.28571.peloquin@mit.edu> <20060809162425.GA7464@xyzzy.farnsworth.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mlachwani@mvista.com, netdev@vger.kernel.org, josejx@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from BISCAYNE-ONE-STATION.MIT.EDU ([18.7.7.80]:22959 "EHLO
	biscayne-one-station.mit.edu") by vger.kernel.org with ESMTP
	id S1750802AbWHIQxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 12:53:54 -0400
In-Reply-To: <20060809162425.GA7464@xyzzy.farnsworth.org>
To: "Dale Farnsworth" <dale@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dale,

Thank you for responding quickly.

This is with gcc 4.1.1 and the config file has been added to the web  
directory at http://web.mit.edu/peloquin/marvell/

Please let me know if I can provide anything else.
Thanks,
-Stuart

On Aug 9, 2006, at 12:24 PM, Dale Farnsworth wrote:

> On Wed, Aug 09, 2006 at 10:47:28AM -0400, Stuart Peloquin wrote:
>> Kernel oops during heavy load downloads with the MV643XX driver on  
>> a PegII.
>> I've replicated the problem on 2.6.17_gentoo-4, vanilla 2.6.17.1,  
>> vanilla
>> 2.6.18_rc3.  When downloading a large file from any fast mirror (I  
>> tested
>> getting around 2.0MB/s) the system crashes after a random amount  
>> of time.
>> Usually after 30seconds to a couple of minutes.
>>
>> I took pictures of the call trace, I'm sorry about the quality,  
>> they were
>> taken with a phone camera.  They can be viewed at
>> http://web.mit.edu/peloquin/marvell
>
> Thanks for the report Stuart.  I'm investigating this now.  Would you
> mind sending me the config file used to build the kernel?  Also, which
> version of gcc are you using?
>
> Thanks,
> -Dale

