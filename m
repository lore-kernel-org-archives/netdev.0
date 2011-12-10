From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Sat, 10 Dec 2011 10:03:50 +0100
Message-ID: <4EE32076.2020706@profihost.ag>
References: <1322773527.2750.27.camel@edumazet-laptop> <4ED86B79.4060506@profihost.ag> <4EE25B06.7010907@profihost.ag> <20111209.142117.357254752872525966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jwboyer@gmail.com, hch@infradead.org,
	netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server655-han.de-nserver.de ([85.158.177.45]:54515 "EHLO
	server655-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751895Ab1LJJDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 04:03:49 -0500
In-Reply-To: <20111209.142117.357254752872525966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.12.2011 20:21, schrieb David Miller:
> From: Stefan Priebe<s.priebe@profihost.ag>
> Date: Fri, 09 Dec 2011 20:01:26 +0100
>
>> any news on that? Systems still crashing every now and then. 3.0.13
>> was released today but i haven't seen any of them.
>
> I only had time to submit these fixes for 3.1.x-stable, you'll just
> have to be incredibly patient.
is it this whole set of 13 patches? 
http://www.spinics.net/lists/netdev/msg182508.html

i will then try to backport them.

Stefan
