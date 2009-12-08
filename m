From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] vhost_net
Date: Tue, 08 Dec 2009 12:47:37 -0800 (PST)
Message-ID: <20091208.124737.56023027.davem@davemloft.net>
References: <200912081349.32763.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, herbert@gondor.apana.org.au
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753285AbZLHUrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 15:47:31 -0500
In-Reply-To: <200912081349.32763.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 8 Dec 2009 13:49:32 +1030

> I've had these sitting in my tree and linux-next; should have pushed
> them out to netdev weeks ago.  Thanks to MST for the ping...

But you in fact didn't push them out, and I specifically stated that
I'm not taking new features into the netdev tree as of Dec 3rd:

	http://marc.info/?l=linux-netdev&m=125988357131776&w=2

I even warned the day previous to that posting how things were going
to work and be enforced.

I've already made too many exceptions, and I'm not making any more,
sorry.

Too many subsystems do not follow the proper procedure, so we have
tons of last minute stuff going in during the merge window.

Feel free to try and merge your bits to Linus directly or whatever,
but it's not going in via my tree, sorry.

I'm not going to be part of the problem. :-)
