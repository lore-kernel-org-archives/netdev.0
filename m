From: "Jaswinder Singh" <jaswinderlinux@gmail.com>
Subject: Firmware patches for Network
Date: Sat, 20 Dec 2008 01:01:17 +0530
Message-ID: <3f9a31f40812191131m48802157r596d7773fb435f34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net,
	"Jeff Garzik" <jeff@garzik.org>,
	"David Woodhouse" <dwmw2@infradead.org>, sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:59001 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753849AbYLSTbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 14:31:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

I have 10 pending patches of firmware for Networking available at
http://git.infradead.org/users/jaswinder/firm-jsr-2.6.git?a=shortlog :

1. firmware: convert e100 driver to request_firmware()

2. firmware: convert acenic driver to request_firmware()

3. firmware: convert tg3 driver to request_firmware()

4. starfire: use request_firmware()

5. myri_sbus: use request_firmware

6. tehuti: use request_firmware

7. typhoon: use request_firmware

8. smc91c92_cs: use request_firmware

9. yam: use request_firmware

10. 3C359: use request_firmware

Please let me know, should I update these patches for :
1. git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
OR
2. git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
OR
3. git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
OR
4. git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

Thank you,

Jaswinder Singh
