From: David Miller <davem@davemloft.net>
Subject: Re: via-velocity: printk of dev->name before name has been
 allocated
Date: Sat, 21 Feb 2009 23:51:52 -0800 (PST)
Message-ID: <20090221.235152.144560236.davem@davemloft.net>
References: <49A04E4B.7080207@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jan.ceuleers@computer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752131AbZBVHwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 02:52:11 -0500
In-Reply-To: <49A04E4B.7080207@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Sat, 21 Feb 2009 19:56:11 +0100

> I have the following in dmesg:
> 
> [   21.212838] VIA Networking Velocity Family Gigabit Ethernet Adapter Driver Ver. 1.14
> [   21.212847] Copyright (c) 2002, 2003 VIA Networking Technologies, Inc.
> [   21.212852] Copyright (c) 2004 Red Hat Inc.
> [   21.212885] ACPI: PCI Interrupt 0000:00:0e.0[A] -> GSI 18 (level, low) -> IRQ 17
> [   21.212937] eth%d: set value of parameter Interrupt service works to 64
> [   21.213684] eth0: VIA Networking Velocity Family Gigabit Ethernet Adapter
> [   21.213691] eth0: Ethernet Address: 00:40:63:F4:AF:DE

This is already fixed in current kernels.

Reporting such things against 6 release old kernels is very near to
pointless, please check against current releases first next time.

Thank you.
