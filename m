From: =?UTF-8?B?TWljaGHFgg==?= <ladnymichal@interia.pl>
Subject: Re: Bug#743399: r8168-dkms: RTL8111/8168/8411 PCI Express Gigabit
 Ethernet Controller (rev 10) needs r8168 to work
Date: Mon, 28 Apr 2014 16:37:12 +0200
Message-ID: <535E6798.9050009@interia.pl>
References: <20140402112255.22479.91586.reportbug@localhost> <53556EE5.1010500@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: 743399@bugs.debian.org, netdev@vger.kernel.org,
	francois romieu <romieu@fr.zoreil.com>,
	realtek linux nic maintainers <nic_swsd@realtek.com>
To: Andreas Beckmann <anbe@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo.poczta.interia.pl ([217.74.65.155]:56666 "EHLO
	smtpo.poczta.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467AbaD1OxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 10:53:22 -0400
In-Reply-To: <53556EE5.1010500@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dnia pon, 21 kwi 2014, 21:17:57 Andreas Beckmann pisze:
> On 2014-04-02 13:22, gnejusz wrote:
>> Dear Maintainer,
>> RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 10) needs
>> realtec module to work.
>>
>> Dmesg output
>> [  712.855476] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>
> You are using the r8169 kernel module, not r8168 ...

Yes, I want to provide all info to develop module r8169 it can be use 
with my card. In everyday use r8168, becuase I'm not able to use the  
Internet.

I've read README.Debian and thought that opening bug is the best 
solution.


"  You may also wish to open a Debian bug report and Cc that."

>
>> What info I need to provide?
>
> Did you modify the blacklist? (/etc/modprobe.d/r8168-dkms.conf)
> Did you reboot after installing r8168-dkms? (To activate the blacklist.)
>
>

> Andreas
>
>
