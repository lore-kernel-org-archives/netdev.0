From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][GENETLINK] move command capabilities to flags
Date: Mon, 04 Dec 2006 19:32:05 -0800 (PST)
Message-ID: <20061204.193205.08322970.davem@davemloft.net>
References: <20061204180000.GU8693@postel.suug.ch>
	<1165266463.3643.46.camel@localhost>
	<20061204212341.GV8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S968053AbWLEDcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 22:32:03 -0500
To: tgraf@suug.ch
In-Reply-To: <20061204212341.GV8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 4 Dec 2006 22:23:41 +0100

> * jamal <hadi@cyberus.ca> 2006-12-04 16:07
> > On Mon, 2006-04-12 at 19:00 +0100, Thomas Graf wrote:
> > > * jamal <hadi@cyberus.ca> 2006-12-04 12:48
> > 
> > > > We can resolve that by uping the version for the controller.
> > > > User will use that a signal.
> > > 
> > > Good idea, makes me happy :-) please do that in your patch as well.
> > 
> > 
> > Ok, here she goes... 
> > If looks good, Dave please apply to net-2.6.20
> 
> Looks good.

Applied, thanks everyone.
