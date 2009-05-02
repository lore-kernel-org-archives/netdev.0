From: David Miller <davem@davemloft.net>
Subject: Re: br2684: convert to net_device_ops broke it
Date: Sat, 02 May 2009 13:49:45 -0700 (PDT)
Message-ID: <20090502.134945.07397681.davem@davemloft.net>
References: <777914.38491.qm@web58405.mail.re3.yahoo.com>
	<20090502134605.GA11168@debian>
	<907051.51698.qm@web58405.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rabin@rab.in, shemminger@vyatta.com, netdev@vger.kernel.org,
	rjw@sisk.pl, linux-kernel@vger.kernel.org
To: mmvinni@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756075AbZEBUtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 16:49:51 -0400
In-Reply-To: <907051.51698.qm@web58405.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikko Vinni <mmvinni@yahoo.com>
Date: Sat, 2 May 2009 13:02:40 -0700 (PDT)

> 
> Rabin Vincent wrote:
> 
>> On Sat, May 02, 2009 at 02:04:21AM -0700, Mikko Vinni wrote:
>> > my ADSL connection works well with kernel 2.6.29, but since commit
>> > 0ba25ff4c669e5395110ba6ab4958a97a9f96922 (br2684: convert to net_device_ops)
>> > entered the mainline using br2684ctl fails with the following bug:
>> [..]
>> > I'll be glad to test any patches.
>> 
>> Please try the one below.
> 
> Yes, that fixes it. Good job and thank you!

Patch applied, thanks everyone.
