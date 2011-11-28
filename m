From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Daughterboard Jetway JAD3RTLANG with three RTL-8110SC/8169SC Gigabit
 Ethernet is curious
Date: Mon, 28 Nov 2011 17:35:05 +0100
Message-ID: <jb0d7u$bbb$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:37514 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab1K1Qf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 11:35:29 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RV4Au-0003bF-E5
	for netdev@vger.kernel.org; Mon, 28 Nov 2011 17:35:24 +0100
Received: from dslb-188-096-081-134.pools.arcor-ip.net ([188.96.81.134])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 17:35:24 +0100
Received: from feldmann_markus by dslb-188-096-081-134.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 17:35:24 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

i have a mini-ITX PC (Motherboard Jetway JNF92-270-LF), whit 3 ethernet 
devices (RTL-8110SC/8169SC Gigabit Ethernet) on one additional 
daughterboard (Jetway JAD3RTLANG).

Here is my <hwinfo --netcard> output:
http://pastebin.com/raw.php?i=Khy1NX61

and dmesg:
http://pastebin.com/raw.php?i=Ziq1mizy

I am using this mini-ITX PC as server/router with a debian 
squeeze/stable system.

My problem is that only one of this three ethernet devices (from the 
daughterboard not the internal one from motherboard) at once is working 
correctly. Sometimes i have only one client to my server connected, but 
only one specific ehernet port is working (mostly the physically upper 
one). I didnt found any regularity yet.

Any hints? is there a specific person whom i schould contact?

regards markus
