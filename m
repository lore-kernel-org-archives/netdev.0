From: Patrick McHardy <kaber@trash.net>
Subject: Re: pkt_sched: add DRR scheduler
Date: Thu, 20 Nov 2008 12:58:11 +0100
Message-ID: <492550D3.7060602@trash.net>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081120115137.GB5275@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56764 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052AbYKTL6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:58:19 -0500
In-Reply-To: <20081120115137.GB5275@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Nov 20, 2008 at 12:42:58PM +0100, Patrick McHardy wrote:
> ...
>   
>> Documentation for this in the kernel tree seems pretty useless though.
>>     
>
> Right! What about iproute2 tree? (examples/?)
>   
Yes, I'll send something when I find some time (manpage probably).

Its trivial to use though, these is only a single optional parameter,
the quantum.

