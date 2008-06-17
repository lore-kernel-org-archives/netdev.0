From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 20:22:20 +0300
Message-ID: <200806172022.20720.denys@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com> <200806170946.17351.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:36812 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785AbYFQRWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 13:22:15 -0400
Received: from localhost (unknown [195.69.208.251])
	by relay2.globalproof.net (Postfix) with ESMTP id B577B13042A
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 20:22:13 +0300 (EEST)
In-Reply-To: <200806170946.17351.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More info. Now it is peak time, and flow control disabled. Before it was 1% packetloss on small packets and 5-6% on large, now it is 0.3% on small, 1-2% on large.
The flow-control required on this particular setup (probably linksys switches is too much crappy, no idea), and without it i experience "small" packetloss"
But seems on this motherboard, by some reasons flow-control not working, maybe it is related to PBA.

I will try to play with PBA now, but not sure i can do that.


-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
