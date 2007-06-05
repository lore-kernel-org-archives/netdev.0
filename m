From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Tue, 05 Jun 2007 10:11:56 +0200
Message-ID: <E1HvU8y-0000xG-00@dorka.pomaz.szeredi.hu>
References: <E1Hv980-0006gQ-00@dorka.pomaz.szeredi.hu>
	<20070605.000247.18308209.davem@davemloft.net>
	<E1HvTgf-0000sb-00@dorka.pomaz.szeredi.hu> <20070605.005521.28788982.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3.sa.ew.hu ([212.108.200.82]:45756 "EHLO
	mail-gw3.sa.ew.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbXFEIML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 04:12:11 -0400
In-reply-to: <20070605.005521.28788982.davem@davemloft.net> (message from
	David Miller on Tue, 05 Jun 2007 00:55:21 -0700 (PDT))
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I just want to win the "who's laziest?" league.  It would take me
> > about 5 minutes to get the netdev tree and test compile the change.
> > Of which 5 seconds would be actually updating the patch.  I was
> > thought it was OK to pass that 5 seconds worth of hard work to you in
> > order to save the rest ;)
> 
> That tradeoff is fine, if, in return you'll do the rest of the
> networking subsystem maintainership work I need to to. :-)

Well, I _did_ save you quite a bit of time by tracking down these
bugs.  That 5 sec of dedication in exchange would have really made me
feel good ;(

Miklos
