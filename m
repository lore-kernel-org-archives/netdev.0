From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/20] net/atm: Cleanups
Date: Tue, 08 Dec 2009 13:21:10 -0800
Message-ID: <1260307270.27677.99.camel@Joe-Laptop.home>
References: <cover.1260251570.git.joe@perches.com>
	 <20091208.131255.259801274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1084 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966369AbZLHVVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 16:21:06 -0500
In-Reply-To: <20091208.131255.259801274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-08 at 13:12 -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon,  7 Dec 2009 21:56:56 -0800
> > Reduced checkpatch complaints, added a couple of cleanup functions
> > to reduce indentation levels
> Joe, if you could respin and resubmit these patches when I open
> net-next-2.6 back up I'd appreciate it.
> It's much too late for the current merge window.

Oh sure, no worries.  They're decidedly trivial.

I was a bit lazy splitting the per-file cleanups
apart in 2-19 and used the same commit message for
each one.  I should probably detail each one anyway. 

cheers, Joe

