From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][Generic netlink]: dont send empty operational
 attributes
Date: Tue, 21 Nov 2006 17:35:56 -0800 (PST)
Message-ID: <20061121.173556.07641543.davem@davemloft.net>
References: <4466a10611191117r3a933644scd0c4182cb08d43c@mail.gmail.com>
	<4466a10611191122r2bd16dbdmc35991c13dc9c92f@mail.gmail.com>
	<20061119195402.GJ8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:61059
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161689AbWKVBf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 20:35:58 -0500
To: tgraf@suug.ch
In-Reply-To: <20061119195402.GJ8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sun, 19 Nov 2006 20:54:02 +0100

> * jamal <hadi@cyberus.ca> 2006-11-19 14:22
> > On 11/19/06, jamal <hadi@cyberus.ca> wrote:
> > >This is probably 2.6.19 material (a little annoyance)
> > >I am testing using a new mailer - if this patch doesnt look right let me
> > know.
> > 
> > Seems like i failed. Ok, heres the patch again..
> 
> HTML mail and application/octet-stream for the patch? :-)
> Probably never made it to netdev. The patch (enclosed again)
> is fine though.
> 
> Dont add operations attribute headers when the family doesnt have
> any (gets annoying to see the header upon first registration
> before the commands are registered)
> 
> signed-off-by: J Hadi Salim

Applied, thanks guys.
