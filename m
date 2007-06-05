From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Tue, 05 Jun 2007 00:55:21 -0700 (PDT)
Message-ID: <20070605.005521.28788982.davem@davemloft.net>
References: <E1Hv980-0006gQ-00@dorka.pomaz.szeredi.hu>
	<20070605.000247.18308209.davem@davemloft.net>
	<E1HvTgf-0000sb-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755513AbXFEHzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 03:55:08 -0400
In-Reply-To: <E1HvTgf-0000sb-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 05 Jun 2007 09:42:41 +0200

> I just want to win the "who's laziest?" league.  It would take me
> about 5 minutes to get the netdev tree and test compile the change.
> Of which 5 seconds would be actually updating the patch.  I was
> thought it was OK to pass that 5 seconds worth of hard work to you in
> order to save the rest ;)

That tradeoff is fine, if, in return you'll do the rest of the
networking subsystem maintainership work I need to to. :-)

