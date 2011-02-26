From: chriss <mail_to_chriss@gmx.net>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Sat, 26 Feb 2011 00:16:49 +0000 (UTC)
Message-ID: <loom.20110226T011347-702@post.gmane.org>
References: <4D32FC1C.3010905@simon.arlott.org.uk> <201101231845.20505.maciej.rutecki@gmail.com> <AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com> <201101241625.45367.maciej.rutecki@gmail.com> <loom.20110205T163216-459@post.gmane.org> <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com> <loom.20110206T203347-475@post.gmane.org> <4D4FE100.5090808@gmail.com> <loom.20110214T141934-88@post.gmane.org> <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:32802 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756553Ab1BZARJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 19:17:09 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Pt7qH-0007xi-K2
	for netdev@vger.kernel.org; Sat, 26 Feb 2011 01:17:01 +0100
Received: from HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de ([109.193.65.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 01:17:01 +0100
Received: from mail_to_chriss by HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 01:17:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse <at> nicira.com> writes:

> 
> What driver is in use with the NIC you are seeing this on?
>

He there

the device in question is (as lspci told)
Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit
Ethernet (rev 10)

handled by kernel module r8169.

I also tried to set up the vlan on the bridge. like br0.3. but that did not work.

regards//chriss

