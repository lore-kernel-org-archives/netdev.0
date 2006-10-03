From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Please pull bcm43xx-d80211 bugfixes and new features
Date: Tue, 03 Oct 2006 10:07:59 -0500
Message-ID: <45227CCF.2000704@lwfinger.net>
References: <200610021843.20694.mb@bu3sch.de> <200610031358.33760.mb@bu3sch.de> <45227569.6070901@lwfinger.net> <200610031648.04932.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:26755 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964801AbWJCPIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 11:08:11 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610031648.04932.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 03 October 2006 16:36, Larry Finger wrote:
>> Michael Buesch wrote:
>>>> kernel: bcm43xx_d80211: firmware revision FE84, patchlevel 90B4, date 2000-14-248
>>>>   29:46:18
>>> Uhm, which firmware are you running?
>> The softmac version reports the following (The "loaded" messages are something I'm trying.):
>>
>> kernel: bcm43xx: Firmware: Microcode "bcm43xx_microcode4.fw" loaded.
>> kernel: bcm43xx: Firmware: PCM "bcm43xx_pcm4.fw" loaded.
>> kernel: bcm43xx: Firmware: InitVals0 "bcm43xx_initval01.fw" loaded.
>> kernel: bcm43xx: Microcode rev 0x123, pl 0x21 (2005-01-22  19:48:06)
> 
> Well, so now you know where the problem is.
> I can't debug this for you ;)
> 

I repulled wireless-dev and rebuilt it to find the same problem, which probably is not in your 
recent patches. When I get a chance, I'll see if I can where it goes wrong.

Larry

