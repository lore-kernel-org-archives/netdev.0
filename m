From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Thu, 15 May 2008 02:45:19 +0400
Message-ID: <20080514224519.GA3739@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <20080514150052.GA15826@2ka.mipt.ru> <20080514213251.GB23758@shareable.org> <20080514220252.GA14378@2ka.mipt.ru> <20080514222837.GF23758@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sage Weil <sage@newdream.net>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37096 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbYENWpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 18:45:34 -0400
Content-Disposition: inline
In-Reply-To: <20080514222837.GF23758@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2008 at 11:28:37PM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> I think that's a fine choice, but it doesn't solve difficult
> problems.  You still have to implement the server cloud. :-)

If that would not be dificult problem, it would not be interesting at
all :)

> It's possible that implementing server cloud protocol _and_ simple
> client protocol may be more work than just server cloud protocol.  I'm
> not sure.  Thoughts welcome.

Well, getting that client protocol is mostly ready, and its design
allows infinite (blah!) extensions and extremely (blah!) flexible
processing, we are close to just difficult server one :)

-- 
	Evgeniy Polyakov
