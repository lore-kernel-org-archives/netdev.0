From: David Miller <davem@davemloft.net>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i
 cannot navigate
Date: Tue, 21 Oct 2008 16:32:07 -0700 (PDT)
Message-ID: <20081021.163207.157978465.davem@davemloft.net>
References: <Pine.LNX.4.64.0810211200170.7072@wrl-59.cs.helsinki.fi>
	<20081021201857.08faf0a7@topolino>
	<20081021184539.GA3320@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sentiniate@tiscali.it, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751957AbYJUXca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 19:32:30 -0400
In-Reply-To: <20081021184539.GA3320@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 21 Oct 2008 20:45:39 +0200

> On Tue, Oct 21, 2008 at 08:18:57PM +0200, Aldo Maggi wrote:
> ...
> > i've compiled 2.6.27.2 source after having patched it with your today's
> > patch.
> > 
> > it works! i.e. i can navigate (w3m kernel.org) and update (apt-get
> > update)
> 
> Ilpo, I should say you're incredible! ...But, since I've promised to
> myself not to disturb you anymore (again), I can't do this, sorry :-(

Indeed, excellent work Ilpo.

Ilpo, now that we know this fixes things for sure, could you submit
this formally with a proper signoff?

I'll queue it up for -stable too.

Thanks!
