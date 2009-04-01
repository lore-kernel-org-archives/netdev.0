From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Q-in-Q ethertypes
Date: Wed, 01 Apr 2009 15:20:54 +0200
Message-ID: <m3r60cse6h.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:49140 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753811AbZDANVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 09:21:14 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Lp0NS-00073O-Rb
	for netdev@vger.kernel.org; Wed, 01 Apr 2009 13:21:10 +0000
Received: from 92.62.204.2 ([92.62.204.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 13:21:10 +0000
Received: from benny+usenet by 92.62.204.2 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 13:21:10 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switches suffer from the delusion that it is necessary to have a
separate ethernet type for Q-in-Q frames instead of just using 0x8100 as
sane people would do.

Would it be possible to support ethertypes 0x9100 and 0x88a8 in the
Linux kernel?


/Benny





