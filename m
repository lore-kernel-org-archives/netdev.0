From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: Linux v2.6.18-rc4
Date: Tue, 8 Aug 2006 19:47:27 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0608081943470.18225@yvahk01.tjqt.qr>
References: <Pine.LNX.4.64.0608061127070.5167@g5.osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer.gwdg.de ([134.76.10.26]:24001 "EHLO mailer.gwdg.de")
	by vger.kernel.org with ESMTP id S1030204AbWHHRrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 13:47:45 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0608061127070.5167@g5.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>It's been a week since -rc3, so now we have a -rc4.

2.6.18 comes with ipt_statistic, but there is no way from userspace 
(iptables) to use it (libipt_statistic.so simply does not come with the 
latest iptables from svn). Does someone know what's going on?



Jan Engelhardt
-- 
