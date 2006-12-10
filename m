From: Andrew Morton <akpm@osdl.org>
Subject: Fw: BUG: Forcedeth & bonding stops working in 2.6.19
Date: Sat, 9 Dec 2006 23:13:45 -0800
Message-ID: <20061209231345.a2716218.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Monnerie <michael.monnerie@it-management.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:57660 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760322AbWLJHOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Dec 2006 02:14:00 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 8 Dec 2006 15:04:28 +0100
From: Michael Monnerie <michael.monnerie@it-management.at>
To: linux-kernel@vger.kernel.org
Subject: BUG: Forcedeth & bonding stops working in 2.6.19


Hello, I currently use 2.6.18.3 with bonding over two forcedeth network 
cards, works pretty well (Asus M32N mainboard, AMD dual core).

I wanted to switch to 2.6.19, but found that - despite it doesn't show 
any errors - the network stops responding shortly after boot. So I went 
back on 2.6.18.3, which has no problems.

In case you need more info on hardware, or testing of patches, please 
write me directly, I'm not on this list. Thank you.

mfg zmi
-- 
// Michael Monnerie, Ing.BSc    -----      http://it-management.at
// Tel: 0676/846914666                        .network.your.ideas.
// PGP Key:        "curl -s http://zmi.at/zmi3.asc | gpg --import"
// Fingerprint: 44A3 C1EC B71E C71A B4C2  9AA6 C818 847C 55CB A4EE
// Keyserver: www.keyserver.net                 Key-ID: 0x55CBA4EE

