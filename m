From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] v3 GRE: TCP segmentation offload
Date: Fri, 15 Feb 2013 17:43:52 -0800
Message-ID: <1360979032.19353.38.camel@edumazet-glaptop>
References: <1360871081-1987-1-git-send-email-pshelar@nicira.com>
	 <20130215.151824.1125629773152171791.davem@davemloft.net>
	 <1360975955.19353.32.camel@edumazet-glaptop>
	 <CALnjE+qsY14H2=PhdPi3yFX7UgBHJgm79z_amw54A4BhEm5hkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com, jesse@nicira.com, bhutchings@solarflare.com,
	mirqus@gmail.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41856 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3BPBnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:43:55 -0500
Received: by mail-pa0-f49.google.com with SMTP id kp6so1955776pab.22
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:43:55 -0800 (PST)
In-Reply-To: <CALnjE+qsY14H2=PhdPi3yFX7UgBHJgm79z_amw54A4BhEm5hkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 17:41 -0800, Pravin Shelar wrote:

> 
> I am not seeing such big difference with these setting, are you
> running this test on special hardware or in VM?

Thats bare metal actually...

processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 44
model name	: Intel(R) Xeon(R) CPU           X5660  @ 2.80GHz
stepping	: 2
microcode	: 0x13
cpu MHz		: 2800.330
cache size	: 12288 KB

...
