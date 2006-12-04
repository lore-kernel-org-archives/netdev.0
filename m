From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][GENETLINK] move command capabilities  to flags
Date: Mon, 4 Dec 2006 22:23:41 +0100
Message-ID: <20061204212341.GV8693@postel.suug.ch>
References: <1165060612.3564.8.camel@localhost> <20061204092041.GN8693@postel.suug.ch> <1165237269.3664.15.camel@localhost> <20061204163115.GR8693@postel.suug.ch> <1165254484.3643.29.camel@localhost> <20061204180000.GU8693@postel.suug.ch> <1165266463.3643.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39285 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967195AbWLDVXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 16:23:21 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1165266463.3643.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-04 16:07
> On Mon, 2006-04-12 at 19:00 +0100, Thomas Graf wrote:
> > * jamal <hadi@cyberus.ca> 2006-12-04 12:48
> 
> > > We can resolve that by uping the version for the controller.
> > > User will use that a signal.
> > 
> > Good idea, makes me happy :-) please do that in your patch as well.
> 
> 
> Ok, here she goes... 
> If looks good, Dave please apply to net-2.6.20

Looks good.
