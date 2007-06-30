From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: 30 Jun 2007 09:51:09 +0200
Message-ID: <m34pkp2842.fsf@ursa.amorsen.dk>
References: <1183121670.5188.16.camel@localhost> <46850450.6040608@trash.net> <46852632.5050707@candelatech.com> <20070629.143650.63998980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:44763 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbXF3Hvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 03:51:45 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I4Xjt-00039K-Fn
	for netdev@vger.kernel.org; Sat, 30 Jun 2007 09:51:29 +0200
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2007 09:51:29 +0200
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2007 09:51:29 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "DM" == David Miller <davem@davemloft.net> writes:

DM> And some people still use hubs, believe it or not.

Hubs are 100Mbps at most. You could of course make a flooding Gbps
switch, but it would be rather silly. If you care about multicast
performance, you get a switch with IGMP snooping.


/Benny


