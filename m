From: clownix <clownix@clownix.net>
Subject: New qdisc monitor
Date: Fri, 02 Oct 2009 18:41:24 +0200
Message-ID: <1254501684.2670.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway09.websitewelcome.com ([69.93.179.27]:50231 "HELO
	gateway09.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753359AbZJBT2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 15:28:01 -0400
Received: from mol92-3-89-80-166-40.dsl.club-internet.fr ([89.80.166.40]:48134 helo=[192.168.1.21])
	by gator713.hostgator.com with esmtpa (Exim 4.69)
	(envelope-from <clownix@clownix.net>)
	id 1MtlCA-0001Hi-2Q
	for netdev@vger.kernel.org; Fri, 02 Oct 2009 11:41:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At http://clownix.net, there is a qdisc monitor based on a new sched
qdisc named spy and a module that periodicaly sends the
enqueues/dequeues/drops/queue-size/delays... to be plotted to the user
world through a netlink socket.
Note that the name of this software package is "clownix_spy", and not
cloonix_net which is another project on the same site.
Regards 
Vincent Perrier

