From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [3.0.y, 3.2.y, 3.4.y] Re: [PATCH 2/2] [sky2] Fix for interrupt
 handler
Date: Mon, 12 Nov 2012 00:24:23 -0800
Message-ID: <20121112082423.GD3581@elie.Belkin>
References: <1341394726.14972.41.camel@mlindner-lin.skd.de>
 <20121025223646.GA1131@elie.Belkin>
 <20121103100447.GA2003@elie.Belkin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Gilbey <jdg@debian.org>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <shemminger@vyatta.org>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35942 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab2KLIY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 03:24:27 -0500
Content-Disposition: inline
In-Reply-To: <20121103100447.GA2003@elie.Belkin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On November 3, Jonathan Nieder wrote:
> On October 25, Jonathan Nieder wrote:
>> Mirko Lindner wrote:

>>> Re-enable interrupts if it is not our interrupt
[...]
>> Tested-by: Julian Gilbey <jdg@debian.org> # 3.2.y, Inspiron 1545
>
> Ping.  Dave, is
>
>   d663d181b9e9 sky2: Fix for interrupt handler
>
> a candidate for inclusion in 3.0-, 3.2-, and 3.4-stable?  (It was
> applied upstream during the 3.6 merge window.)

Please confirm or object so I know you've received this message.
Thanks for maintaining netdev-stable with such attention to quality,
by the way.

Sincerely,
Jonathan
