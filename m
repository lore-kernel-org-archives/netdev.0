From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: next-20081117: kernel freezes with netconsole enabled
Date: Fri, 21 Nov 2008 19:52:02 +0300
Message-ID: <a4423d670811210852q739a3929g23a0476927bbcc11@mail.gmail.com>
References: <20081119175740.GE12456@orion> <1227119251.3149.57.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, satyam.sharma@gmail.com
To: "Matt Mackall" <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.188]:14286 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbYKUQwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:52:04 -0500
Received: by rn-out-0910.google.com with SMTP id k40so875213rnd.17
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 08:52:03 -0800 (PST)
In-Reply-To: <1227119251.3149.57.camel@calx>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/11/19 Matt Mackall <mpm@selenic.com>:
> On Wed, 2008-11-19 at 20:57 +0300, Alexander Beregalov wrote:
>> Hi
>>
>> It is x86_64 SMP
>> The kernel freezes while transferring kernel log through netconsole,
>> SysRq does not work at that moment.
>
> Does it survive if you boot with 'quiet'? Is this new behavior or have
> you successfully used netconsole before?

`queit` parameter does not help. The problem happens on 2.6.28-rc6 and
2.6.27 as well.
I will try older kernels next week.
