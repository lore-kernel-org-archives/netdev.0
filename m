From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Mon, 30 Jan 2012 09:38:54 +0100
Message-ID: <4F26571E.1010002@profihost.ag>
References: <1322773527.2750.27.camel@edumazet-laptop> <4ED86B79.4060506@profihost.ag> <4EE25B06.7010907@profihost.ag> <20111209.142117.357254752872525966.davem@davemloft.net> <4EE32076.2020706@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jwboyer@gmail.com, hch@infradead.org,
	netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:32864 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab2A3Iph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 03:45:37 -0500
In-Reply-To: <4EE32076.2020706@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Hi Greg, Hi List,

Am 10.12.2011 10:03, schrieb Stefan Priebe:
> Am 09.12.2011 20:21, schrieb David Miller:
>> From: Stefan Priebe<s.priebe@profihost.ag>
>> Date: Fri, 09 Dec 2011 20:01:26 +0100
>>
>>> any news on that? Systems still crashing every now and then. 3.0.13
>>> was released today but i haven't seen any of them.
>>
>> I only had time to submit these fixes for 3.1.x-stable, you'll just
>> have to be incredibly patient.

this bug sadly still makes the actual STABLE tree of the kernel
unusable. I mean nearly everbody uses TCP/IP.

Is there any progress or ETA regardings this issue?

Thanks a lot!

Stefan
