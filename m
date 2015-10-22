From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 06:12:14 -0700 (PDT)
Message-ID: <20151022.061214.1694435563929586307.davem@davemloft.net>
References: <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>
	<5628CF79.2000507@oracle.com>
	<1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan.Burlison@oracle.com, Casper.Dik@oracle.com,
	viro@ZenIV.linux.org.uk, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757168AbbJVMzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 08:55:50 -0400
In-Reply-To: <1445515858.22974.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 Oct 2015 05:10:58 -0700

> I am a major linux networking developper and wont accept linux is
> hijacked by guys who never contributed to it, just so it meets their
> unreasonable expectations.
> 
> We absolutely care about performance. And I do not care you focus on
> POSIX crap.

+1
