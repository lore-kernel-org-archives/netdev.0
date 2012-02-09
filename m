From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Thu, 09 Feb 2012 07:43:33 +0100
Message-ID: <4F336B15.3080608@profihost.ag>
References: <20120202.143957.2251106530056768980.davem@davemloft.net> <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag> <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag> <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F2F971B.9090503@profihost.ag> <1328519818.2220.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F2FBA16.8010400@profihost.ag> <4F323138.2040200@profihost.ag> <20120208164950.GA13596@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:49313 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab2BIGni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 01:43:38 -0500
In-Reply-To: <20120208164950.GA13596@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 08.02.2012 17:49, schrieb Greg KH:
> On Wed, Feb 08, 2012 at 09:24:24AM +0100, Stefan Priebe - Profihost AG wrote:
>> Hi Greg, Hi Eric,
>>
>> Am 06.02.2012 12:31, schrieb Stefan Priebe - Profihost AG:
>>>> make   $your_favorite_build_options
>>>
>>> here is the missing patch attached to have a fine build with
>>> allyesconfig.allyesconfig
>>
>> Amy news on my patches? Can they get integrated into 3.0.X stable series?
> 
> I will consider them after this next release goes out, and I get a
> chance to review and test them.
> 
> Don't worry, they are in my "to-review" queue, they are not lost.

Thanks! Just wanted to know that.

Stefan
