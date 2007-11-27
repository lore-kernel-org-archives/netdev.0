From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 23:37:43 +0100
Message-ID: <20071127223743.GI24223@one.firstfloor.org>
References: <20071122343.446909000@suse.de> <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com> <200711271549.37670.rusty@rustcorp.com.au> <1196202698.3415.119.camel@jcmlaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34097 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbXK0Whp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 17:37:45 -0500
Content-Disposition: inline
In-Reply-To: <1196202698.3415.119.camel@jcmlaptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> With my "Enterprise" hat on, I can see where Andi was coming from
> originally. 

For the record my original motivation was to fix the "TCP exports everything
for ipv6.ko" case cleanly. I later realized that it would be useful for the
ABI stability issues too, but it was really not my primary motivation.
This is why I didn't even mention that in the original patch description.

-Andi

