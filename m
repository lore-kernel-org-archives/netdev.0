From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Fri, 10 Feb 2012 08:04:29 +0100
Message-ID: <4F34C17D.6070805@profihost.ag>
References: <1328253972.2480.42.camel@edumazet-laptop>	<4F2B963F.4020504@profihost.ag>	<20120208.202651.97221367956126026.davem@davemloft.net> <20120209.171320.1013450846926790034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregkh@linuxfoundation.org,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:57496 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab2BJHEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:04:36 -0500
In-Reply-To: <20120209.171320.1013450846926790034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 09.02.2012 23:13, schrieb David Miller:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 08 Feb 2012 20:26:51 -0500 (EST)
> 
>> I'll work on coming up with something much more sensible tonight.
> 
> Ok, here's what I'm testing right now, please review and test.

thanks for doing this work! I can't test asap as i can't do udpates just
for fun. I had the "luck" that last time there was the security bug
recarding /proc/mem so i was  able to schedule it pretty fast.

At least the patch applies fine ;-)

Thanks!

Stefan
