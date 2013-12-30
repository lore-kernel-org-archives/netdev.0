From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 30 Dec 2013 14:22:58 +0100
Message-ID: <DUB123-W12B3536BD1E69D2E88A512EDCE0@phx.gbl>
References: <CALU-w9860x_rWhu35v50N39b8AxiPB_wOk1OUKdBr9eBLzEZFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: =?iso-8859-1?B?RmVqZXMgSvN6c2Vm?= <jozsef.fejes@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s30.dub0.hotmail.com ([157.55.0.229]:48734 "EHLO
	dub0-omc1-s30.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751542Ab3L3N2s convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Dec 2013 08:28:48 -0500
In-Reply-To: <CALU-w9860x_rWhu35v50N39b8AxiPB_wOk1OUKdBr9eBLzEZFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


> I'm having the issue mentioned in the subject line with the latest
> stable kernel, 3.12.6.
>
> This network controller is integrated into a D945GSEJT motherboard, dmesg info:
>
> [ 2.216912] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [ 2.217341] r8169 0000:01:00.0: irq 44 for MSI/MSI-X
> [ 2.217852] r8169 0000:01:00.0 eth0: RTL8168d/8111d at 0xdff16000,
> 00:27:0e:01:af:d5, XID 081000c0 IRQ 44
> [ 2.217869] r8169 0000:01:00.0 eth0: jumbo features [frames: 9200
> bytes, tx checksumming: ko]
>
> I pasted the syslog message here: http://pastebin.com/6pqd03Jc

> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.6-joco #1

Looks like 3.11.6, not 3.12.6?


Lukas 		 	   		  