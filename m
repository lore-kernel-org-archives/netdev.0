From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Jetway JAD3RTLANG, Daughter Board, 3x GigaBit LAN does not work correctly
Date: Thu, 03 Mar 2011 22:02:40 +0100
Message-ID: <ikovkn$bn8$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:32876 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708Ab1CCVC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 16:02:27 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PvFfG-0005hU-52
	for netdev@vger.kernel.org; Thu, 03 Mar 2011 22:02:26 +0100
Received: from dslb-188-096-092-238.pools.arcor-ip.net ([188.96.92.238])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 22:02:26 +0100
Received: from feldmann_markus by dslb-188-096-092-238.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 22:02:26 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

i have a mini-ITX server with the mainboard "Jetway JNF92-270-LF" with 
the daughterboard "Jetway JAD3RTLANG, 3x GigaBit LAN".

My current kernel is 2.6.36.4 and i can only connect over one of the 
network interfaces of my daughterboard at the time.

My loaded modules:
http://pastebin.com/raw.php?i=C9u78SML

And a list of pci devices:
http://pastebin.com/raw.php?i=f00tTdEJ

I am using a bridge br0 to bind all three interfaces eth1, eth2 and eth3 
together:
http://pastebin.com/raw.php?i=deUT7iVS

Do i have to configure anything in my kernel to fit this daughterboard?

regards Markus

