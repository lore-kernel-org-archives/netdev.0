From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 20:29:23 +0100
Message-ID: <49B96293.7040003@weinigel.se>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se> <20090312190517.GD24995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:35463 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbZCLT31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:29:27 -0400
In-Reply-To: <20090312190517.GD24995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> You didn't read what I wrote very closely, I specifically said you have to dig
> or host to do name lookups, specifically because of the issues with getXbyY.

Did too.  :-)

> 3) Your knoweldge from (1) is insufficient to implement the required initramfs in (2)
> in (assuming your example time frame) 1 week?
> 
> Seriously?

Yup.  A week right now is a luxury I usually don't have right now.
I shouldn't even be spending time writing this mail, but I'm eh,
right, waiting for a compilation to finish.

>> Anyway, I've spent more time on discussing this now than it would have  
>> taken me to hack the device drivers on half a dozen platforms, so I  
>> think I'll give up.  Maybe I'll take a look at some initrd+klibc+dhcp  
>> stuff when I have some free time next Christmas (that's when I usually  
>> get to play around with my hobby projects), maybe not. :-)
>>
> I sympathize with you.  This is exactly what soured me on embedded work a few
> years back.  Embedded shops are forever compromising doing things correctly in
> the name of time and schedules, never paying any heed to the possibility that
> taking extra time to do things in an agreed upon, organized and standard fashion
> might pay off for them in the long run.  

Actually, I'm quite happy about work so far.  When worked on improving 
the Samsung S3C24A0 patches Sandeep Patil had made, I got approval from 
my boss to spend time on making them suitable for submission to the 
official kernel, so I was able to do a lot more than just "make things 
work now".  But the last few months have been kind of hectic.

   /Christer
