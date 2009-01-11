From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Allowing more than 64k connections and heavily optimize bind(0) time.
Date: Sun, 11 Jan 2009 15:52:06 +0300
Message-ID: <20090111125206.GA24173@ioremap.net>
References: <20081224190926.GA3244@ioremap.net> <20081225212928.GA12038@ioremap.net> <20090110105931.GB358@ioremap.net> <20090110.232019.98466627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:34861 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397AbZAKMwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 07:52:09 -0500
Content-Disposition: inline
In-Reply-To: <20090110.232019.98466627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 10, 2009 at 11:20:19PM -0800, David Miller (davem@davemloft.net) wrote:
> > I'm getting out from the vacations tomorrow and will try to more
> > extensively test the patch (QA group found a bug in ipv6 side, but that
> > was with the .24 backported patch, current one does not have that codepath
> > iirc). But I would like to know if this worth it.
> 
> I'll look at it at some point but it won't make this merge window,
> sorry.

Ok, please drop me a not and if things are good, merge the patch
into the appropriate tree for the next window when time permits.

-- 
	Evgeniy Polyakov
