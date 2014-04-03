From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Bug(s) with netconsole (using mv643xx_eth on Kirkwood)
Date: Thu, 3 Apr 2014 11:44:14 -0700
Message-ID: <CAGVrzcbLt9Cn=vBP0TFT5Wri7gzxmoVcezYNMfb92xcSZrmndQ@mail.gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de>
 <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com>
 <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com>
 <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de>
 <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de>
 <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de>
 <533D8207.2050108@gmail.com> <533D8518.1010306@ahsoftware.de>
 <533DA12B.8090904@ahsoftware.de> <533DA69A.2010402@gmail.com> <533DAAD7.40000@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	David Miller <davem@davemloft.net>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:37501 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbaDCSoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 14:44:55 -0400
In-Reply-To: <533DAAD7.40000@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-03 11:39 GMT-07:00 Alexander Holler <holler@ahsoftware.de>:
> Am 03.04.2014 20:21, schrieb Sebastian Hesselbarth:
>>
>> On 04/03/2014 07:58 PM, Alexander Holler wrote:
>
>
>>> I hope everyone who missed some more information is happy now, otherwise
>>> I (again) wasted time to type a problem description (not to speak about
>>> the already spent time trying to diagnose the problem)
>>>
>>> So go on and try to take the almost low hanging fruit. I'm not sure if I
>>> will spend more time on that topic as I already have a working
>>> patch/workaround and the discussion has become a bit tiresome. Sorry.
>>
>>
>> Alexander, please stop f*cking around here. Florian, David, and me
>> already showed a lot patience. None of your patches deals with the
>> real issue. Either help others to properly reproduce it or leave it.
>
>
> I haven't requested help.
>
> I've send a patch which fixed a problem here I had with a new reset. The
> problem appears inside the reset (the reset doesn't end), so the patch
> looked very reasonable. That's all.

You said so yourself, your patch is a workaround. What Sebastian is
asking for, which is perfectly reasonable is for you to root cause
this, since 1) he is not able to reproduce the problem, 2) the initial
patch is not acceptable as-is because it lacks too many critical
pieces of information.
-- 
Florian
