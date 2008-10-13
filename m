From: David Miller <davem@davemloft.net>
Subject: Re: Please pull - generic HDLC
Date: Mon, 13 Oct 2008 11:23:09 -0700 (PDT)
Message-ID: <20081013.112309.129955744.davem@davemloft.net>
References: <20081012.144704.39192150.davem@davemloft.net>
	<20081013055356.GA29938@cs181140183.pp.htv.fi>
	<m31vyk4kde.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753068AbYJMSXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 14:23:33 -0400
In-Reply-To: <m31vyk4kde.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 13 Oct 2008 16:53:17 +0200

> Adrian Bunk <bunk@kernel.org> writes:
> 
> > The over 3 weeks old -next already contains mostly the same as the HDLC 
> > tree contains now.
> >
> > The thing you two should sort out is why the tree ended up as an own 
> > tree in -next instead of pull requests to David long ago.
> >
> > E.g. the netdev and wireless trees also don't go into -next, but instead 
> > with frequent pull requests to David.
> 
> I can't see any problem with this, is there any?
> 
> I want the HDLC tree tested in next before it's merged upstream
> (= David's tree(s)). I don't want to push crap upstream  first and
> only then try to fix it (though a bug still slips in sometimes).

You're supposed to have your changes merged into the relevant
subsystem tree long before Linus's merge window opens up.

That's how it is meant to work.

What I'm doing with networking is nothing special.

So please be punctual and merge early and often to Jeff and
myself, so that you don't miss the merge window in the future.
