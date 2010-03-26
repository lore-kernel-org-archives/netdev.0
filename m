From: Lee <lee-in-berlin@web.de>
Subject: Re: WARNING: at net/sched/sch_generic.c:261 dev_watchdog+0x249/0x260()
Date: Fri, 26 Mar 2010 15:17:33 +0100
Message-ID: <4BACC1FD.3000609@web.de>
References: <4BA7D897.9050407@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:56901 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510Ab0CZOTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 10:19:43 -0400
Received: from smtp05.web.de (fmsmtp05.dlan.cinetic.de [172.20.4.166])
	by fmmailgate01.web.de (Postfix) with ESMTP id E1E68151A5E89
	for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 15:17:34 +0100 (CET)
Received: from [85.178.194.82] (helo=[10.48.0.23])
	by smtp05.web.de with asmtp (TLSv1:AES256-SHA:256)
	(WEB.DE 4.110 #4)
	id 1NvALu-0007H1-00
	for netdev@vger.kernel.org; Fri, 26 Mar 2010 15:17:34 +0100
In-Reply-To: <4BA7D897.9050407@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

As this mail went unanswered, did I forget anything? Was it too verbose? 
Should I file a bug report on bugzilla.kernel.org instead?

Regards,
Lee

On 22/03/10 21:52, Lee wrote:
> Hi everyone,
>
> I get a kernel oops on 2.6.32.10 when I use an rt73usb WLAN stick with
> hostapd 0.6.10. It's bridged with one of my ethernet (r8169) interfaces.
> When I have the stick plugged in without hostapd, the kernel oops
> doesn't happen. It's not easily triggered, it usually happens within a
> few hours of use with hostapd. I have about a dozen of those from while
> tracking this bug down, if needed.
>
> Everything seems to work fine (before and after the oops), but at least
> on one occasion I had a large delay on my ssh line when the oops happened.
>
> I have no idea what is causing this, but will happily test any patches
> that are handed in my direction :)
>
> Kernel oops, .config and hostapd.conf are attached. Please tell me if
> anything else is needed to hunt down this bug.
>
> Regards,
> Lee


