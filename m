From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net/wanrouter?
Date: Thu, 24 May 2012 09:13:10 -0700
Message-ID: <20120524091310.1c01577e@nehalam.linuxnetplumber.net>
References: <1337708034.3432.0.camel@joe2Laptop>
	<4FBE3CFC.6070103@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48984 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933394Ab2EXQNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 12:13:16 -0400
In-Reply-To: <4FBE3CFC.6070103@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 May 2012 15:51:56 +0200
Jan Ceuleers <jan.ceuleers@computer.org> wrote:

> On 05/22/2012 07:33 PM, Joe Perches wrote:
> > Does anyone still use this?
> 
> I have the hardware (a Sangoma ADSL PCI card) but am no longer using it.
> Also, as I remember, Sangoma stopped contributing to the upstream driver
> many years ago while still actively developing the out-of-tree version.

The wanrouter code hasn't supported Sangoma hardware for a long time,
it got removed early in 2.6.

There are a bunch of old T1 and T3 cards there but I doubt any of them
are still for sale. But somebody is probably still using them.
