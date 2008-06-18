From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: netlink circular locking dependency
Date: Wed, 18 Jun 2008 13:38:23 +0200
Message-ID: <1213789103.19872.0.camel@violet.holtmann.net>
References: <20080617134303.GC4632@ff.dom.local>
	 <20080617.213012.132043917.davem@davemloft.net>
	 <4858CCCE.7060404@trash.net>
	 <20080618.020831.214323427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jarkao2@gmail.com, netdev@vger.kernel.org,
	mingo@elte.hu, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55319 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbYFRLew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 07:34:52 -0400
In-Reply-To: <20080618.020831.214323427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> > > In the meantime should I apply Patrick's current patch
> > > from this thread?
> > 
> > I think that makes sense, the module unload race is present anyway.
> > >
> > > If so I'd like a proper commit message and signoff, thanks!
> > 
> > Attached the patch with a proper changelog.
> 
> Applied and pushed out to net-2.6, thanks a lot Patrick.

you could have added a Tested-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


