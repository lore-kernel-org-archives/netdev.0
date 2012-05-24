From: Joe Perches <joe@perches.com>
Subject: Re: net/wanrouter?
Date: Thu, 24 May 2012 09:22:57 -0700
Message-ID: <1337876577.5070.7.camel@joe2Laptop>
References: <1337708034.3432.0.camel@joe2Laptop>
	 <4FBE3CFC.6070103@computer.org>
	 <20120524091310.1c01577e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38666 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757619Ab2EXQXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 12:23:00 -0400
In-Reply-To: <20120524091310.1c01577e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-24 at 09:13 -0700, Stephen Hemminger wrote:
> On Thu, 24 May 2012 15:51:56 +0200
> Jan Ceuleers <jan.ceuleers@computer.org> wrote:
> 
> > On 05/22/2012 07:33 PM, Joe Perches wrote:
> > > Does anyone still use this?
> > 
> > I have the hardware (a Sangoma ADSL PCI card) but am no longer using it.
> > Also, as I remember, Sangoma stopped contributing to the upstream driver
> > many years ago while still actively developing the out-of-tree version.
> 
> The wanrouter code hasn't supported Sangoma hardware for a long time,
> it got removed early in 2.6.
> 
> There are a bunch of old T1 and T3 cards there but I doubt any of them
> are still for sale. But somebody is probably still using them.

I'm sure people are still using token ring
too, just not with recent kernels.

I think wanrouter is old and dusty and can
be removed just like TR.
