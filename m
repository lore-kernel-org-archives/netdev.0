From: =?ISO-8859-1?Q?Fejes_J=F3zsef?= <jozsef.fejes@gmail.com>
Subject: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 30 Dec 2013 10:57:24 +0100
Message-ID: <CALU-w9860x_rWhu35v50N39b8AxiPB_wOk1OUKdBr9eBLzEZFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:37752 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817Ab3L3J51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 04:57:27 -0500
Received: by mail-we0-f181.google.com with SMTP id x55so9863438wes.40
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 01:57:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm having the issue mentioned in the subject line with the latest
stable kernel, 3.12.6.

This network controller is integrated into a D945GSEJT motherboard, dmesg info:

[    2.216912] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.217341] r8169 0000:01:00.0: irq 44 for MSI/MSI-X
[    2.217852] r8169 0000:01:00.0 eth0: RTL8168d/8111d at 0xdff16000,
00:27:0e:01:af:d5, XID 081000c0 IRQ 44
[    2.217869] r8169 0000:01:00.0 eth0: jumbo features [frames: 9200
bytes, tx checksumming: ko]

I pasted the syslog message here: http://pastebin.com/6pqd03Jc

Can you please help me with this issue?

Please CC me, I'm not subscribed.

Thanks, Jozsef
