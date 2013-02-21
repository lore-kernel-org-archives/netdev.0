From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Problem with Reaktek 8168
Date: Thu, 21 Feb 2013 23:45:43 +0100
Message-ID: <20130221224543.GA11240@electric-eye.fr.zoreil.com>
References: <5124B909.4080907@online.de> <20130220231122.GA22163@electric-eye.fr.zoreil.com> <51256EC7.90505@online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ralf Friedl <Ralf.Friedl@online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32837 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab3BUXRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 18:17:30 -0500
Content-Disposition: inline
In-Reply-To: <51256EC7.90505@online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ralf Friedl <Ralf.Friedl@online.de> :
[...]
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:02:00.0: irq 90 for MSI/MSI-X
> r8169 0000:02:00.0: eth0: RTL8168f/8111f at 0xffffc90010122000,
> 50:46:5d:a7:30:7a, XID 08000880 IRQ 90

Thanks.

I have not noticed 8168f specific problems as of late. It could be worth
giving stock 3.8 a try though: its load of changes includes some post
3.4.x branch 8168f bits.

-- 
Ueimor
