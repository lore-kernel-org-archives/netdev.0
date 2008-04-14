From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 12:16:08 +0200
Message-ID: <20080414101608.GA18662@one.firstfloor.org>
References: <47FEADCB.7070104@rtr.ca> <22880.1207943922@turing-police.cc.vt.edu> <47FFE5DA.8000709@imap.cc> <200804132040.12138.rjw@sisk.pl> <20080413184730.GD8474@1wt.eu> <874pa4wyfj.fsf@basil.nowhere.org> <20080414100018.GA10378@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56353 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbYDNKLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 06:11:14 -0400
Content-Disposition: inline
In-Reply-To: <20080414100018.GA10378@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> And most of all, the reporter would not feel like the bisection is
> the default response !

Well it is proportional to the quality of the bug report. If it 
very vague enough often there is no other good answer. If it
comes with already some debugging or good logs or a good test case 
etc. I agree just saying "please bisect" is not very nice (but
sometimes it might be still needed if code review doesn't find
anything)

Perhaps there should be a document somewhere explaining this which
can be easily pointed to.

-Andi
