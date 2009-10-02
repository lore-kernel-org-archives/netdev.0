From: clownix <clownix@clownix.net>
Subject: clownix_spy: qdisc monitor + generic kernel variable plotter
Date: Fri, 02 Oct 2009 20:15:48 +0200
Message-ID: <1254507348.5236.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway04.websitewelcome.com ([67.18.39.3]:52277 "HELO
	gateway04.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751542AbZJCFWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 01:22:25 -0400
Received: from mol92-3-89-80-166-40.dsl.club-internet.fr ([89.80.166.40]:41329 helo=[192.168.1.21])
	by gator713.hostgator.com with esmtpa (Exim 4.69)
	(envelope-from <clownix@clownix.net>)
	id 1MtmfX-000264-4N
	for netdev@vger.kernel.org; Fri, 02 Oct 2009 13:15:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At http://clownix.net, there is a qdisc monitor based on a sched
qdisc named "spy" and a module that periodicaly sends the
enqueues/dequeues/drops/queue-size/delays... to be gtk-plotted to the
user world (through a netlink socket).

With a few lines written in a module, any kernel variable can be
plotted.

Note that the name of this software package is "clownix_spy", and not
cloonix_net which is another project on the same site.
Regards 
Vincent Perrier

