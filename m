From: Marcus Better <marcus@better.se>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Tue, 04 Jul 2006 21:38:39 +0200
Message-ID: <e8eg49$f2o$1@sea.gmane.org>
References: <e82qhq$4v0$1@sea.gmane.org> <20060630211604.GA5302@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:64747 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S932349AbWGDTkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 15:40:05 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Fxqjy-0007b1-2O
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 21:39:24 +0200
Received: from 67.152.216.81.static.g-va.siw.siwnet.net ([81.216.152.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2006 21:39:22 +0200
Received: from marcus by 67.152.216.81.static.g-va.siw.siwnet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2006 21:39:22 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> In a better world, you would narrow the suspect with a git bissect [1]
> between v2.6.15 and v2.6.16.

Will try. It may take some time...

Marcus


