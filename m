From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Allowing more than 64k connections and heavily optimize bind(0) time.
Date: Sun, 11 Jan 2009 16:09:16 +0300
Message-ID: <20090111130916.GA25337@ioremap.net>
References: <20081224190926.GA3244@ioremap.net> <20090110.232019.98466627.davem@davemloft.net> <20090111125206.GA24173@ioremap.net> <200901111503.10736.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:46427 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbZAKNJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 08:09:20 -0500
Content-Disposition: inline
In-Reply-To: <200901111503.10736.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 03:03:10PM +0200, Denys Fedoryschenko (denys@visp.net.lb) wrote:
> I did test on loaded squid.
> 
> 49878 connections established ,1421/sec
> It is not peak time yet, passed 24 hours testing.
> 
> I can't compare load, because it is real life load and always vary, but thing 
> i can say, it doesn't crash :-)

Thanks a lot for giving this a try Denys!

-- 
	Evgeniy Polyakov
