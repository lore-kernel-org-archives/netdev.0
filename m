From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take22 0/4] kevent: Generic event handling mechanism.
Date: Tue, 07 Nov 2006 07:05:53 -0500
Message-ID: <455076A1.3000707@garzik.org>
References: <5c49b0ed0611021140u360342f2v1e83c73d03eea329@mail.gmail.com>	<20061103084240.GB1184@2ka.mipt.ru>	<20061103085712.GA3725@elf.ucw.cz> <20061103.010413.85690195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, johnpol@2ka.mipt.ru, nate.diller@gmail.com,
	linux-kernel@vger.kernel.org, olecom@flower.upol.cz,
	drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org,
	chase.venters@clientec.com, johann.borck@densedata.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33977 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1754219AbWKGMF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 07:05:57 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061103.010413.85690195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pavel Machek <pavel@ucw.cz>
> Date: Fri, 3 Nov 2006 09:57:12 +0100
> 
>> Not sure what you are smoking, but "there's unsigned long in *bsd
>> version, lets rewrite it from scratch" sounds like very bad idea. What
>> about fixing that one bit you don't like?
> 
> I disagree, it's more like since we have to be structure incompatible
> anyways, let's design something superior if we can.

Definitely agreed.

	Jeff



