From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 05:10:58 -0700
Message-ID: <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
	 <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com>
	 <201510220615.t9M6FL2d017592@room101.nl.oracle.com>
	 <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5628CF79.2000507@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, David Miller <davem@davemloft.net>,
	viro@ZenIV.linux.org.uk, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35328 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757202AbbJVMLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 08:11:00 -0400
Received: by pasz6 with SMTP id z6so85595513pas.2
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 05:11:00 -0700 (PDT)
In-Reply-To: <5628CF79.2000507@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-22 at 12:58 +0100, Alan Burlison wrote:
> On 22/10/2015 12:30, Eric Dumazet wrote:
> 
> > We absolutely do not _want_ to do this just so that linux becomes slower
> > to the point Solaris can compete, or you guys can avoid some work.
> 
> Sentiments such as that really have no place in a discussion that's been 
> focussed primarily on the behaviour of interfaces, albeit with 
> digressions into the potential performance impacts. The discussion has 
> been cordial and I for one appreciate Al Viro's posts on the subject, 
> from which I've leaned a lot. Can we please keep it that way? Thanks.

Certainly not.

I am a major linux networking developper and wont accept linux is
hijacked by guys who never contributed to it, just so it meets their
unreasonable expectations.

We absolutely care about performance. And I do not care you focus on
POSIX crap.
