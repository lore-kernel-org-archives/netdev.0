From: Zbigniew Luszpinski <zbiggy@o2.pl>
Subject: Re: vmxnet3 driver broken since 3.0?
Date: Sun, 11 Dec 2011 22:38:54 +0000 (UTC)
Message-ID: <loom.20111211T232956-373@post.gmane.org>
References: <CAJeBh4sXMVnZcLcjiMyvpPPoG3708CeaQ3hDj_g2s72Hv09N6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:38343 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab1LKWpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Dec 2011 17:45:09 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RZs8q-00038I-09
	for netdev@vger.kernel.org; Sun, 11 Dec 2011 23:45:08 +0100
Received: from 202.etlink.pl ([202.etlink.pl])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2011 23:45:07 +0100
Received: from zbiggy by 202.etlink.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2011 23:45:07 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alessandro Salvatori <sandr8 <at> gmail.com> writes:
> haven't had a chance to try the one from the 3.2 release candidates yet.

In 3.2-rc5 is still broken. Exactly the same error you get. :(
Someone introduced a change since kernel 3.0 which broke vmxnet3 driver. And
this breaking change continues in kernel 3.1 and 3.2-rc5 so it seems it will not
go away. :(

have a nice day,
Zbigniew Luszpinski
