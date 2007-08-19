From: Kevin E <kevin360@yahoo.com>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sun, 19 Aug 2007 09:42:08 -0700 (PDT)
Message-ID: <623107.14278.qm@web38905.mail.mud.yahoo.com>
References: <20070819093221.4d3291e9@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38905.mail.mud.yahoo.com ([209.191.125.111]:26197 "HELO
	web38905.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753898AbXHSQmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2007 12:42:09 -0400
In-Reply-To: <20070819093221.4d3291e9@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Hemminger
<shemminger@linux-foundation.org> wrote:

> The working board has a different version of the
> Marvell chip:
> 
> $ grep Marvell working-MB 
> 04:00.0 Ethernet controller: Marvell Technology
> Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller
> (rev 14)
> $ grep Marvell broken-MB 
> 04:00.0 Ethernet controller: Marvell Technology
> Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller
> (rev 12)
> 
> Not sure if that completely explains the problem
> because the broken chip on my
> system is:
> 06:00.0 Ethernet controller: Marvell Technology
> Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller
> (rev 14)
> 
> I don't know what the differences are between
> versions.

Since I have a rev 14 that works and you have a rev 14
that doesn't work, is there any other info I can
provide to you that would maybe help in figuring out
how you can get your board working?



       
____________________________________________________________________________________
Looking for a deal? Find great prices on flights and hotels with Yahoo! FareChase.
http://farechase.yahoo.com/
