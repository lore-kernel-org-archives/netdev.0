From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NetDev! Please help!
Date: Sun, 21 Sep 2008 18:11:37 +0200
Message-ID: <48D67239.9040006@gmail.com>
References: <48D4F85C.8090709@bigtelecom.ru> <200809202111.01256.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:28383 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbYIUQHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 12:07:42 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1095996fgg.17
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2008 09:07:40 -0700 (PDT)
In-Reply-To: <200809202111.01256.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 09/20/2008 08:11 PM:
...

> P.S. For netdev, i have one more friend - who is complaining that shapers is 
> crashing on Intel machines (who uses TSC, he have two different "Core" based 
> servers, and both is crashing). With HPET i dont have any problem on high 
> performance shapers (except, that it is CPU expensive). It happens on latest 
> 2.6.26.5 too. Machine getting hard lockup, and nothing than hardware watchdog 
> able to recover it. They dont have experience to get actual reason of this 
> issue and they dont know english well to report this issue.

Is your friend sure it's because of shapers? If he/she can patch
there is no need to know English well to report here:

Subject: 2.6.26.5 tc not OK

Config:
	.config

tc script:
	script

dmesg:
	dmesg

not OK when: script run/script not run

patch #1 not OK
patch #2 not OK
...
patch #2001 OK!

Jarek P.
