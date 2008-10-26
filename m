From: Martin Capitanio <c4p7n@capitanio.org>
Subject: Re: [PATCH] r8169: Increase version number
Date: Sun, 26 Oct 2008 06:07:02 +0100
Message-ID: <1224997622.8214.7.camel@marvin>
References: <1224589239.23443.30.camel@marvin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:26840 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbYJZFHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 01:07:12 -0400
In-Reply-To: <1224589239.23443.30.camel@marvin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-21 at 13:40 +0200, Martin Capitanio wrote:
> An ubuntu user reported me 8101e success:
> 
> [    0.000000] Linux version 2.6.27-7-generic (buildd@palmer) (gcc version 4.3.2 (Ubuntu 4.3.2-1ubuntu10) ) #1 SMP Fri Oct 17 22:24:21 UTC 2008 (Ubuntu 2.6.27-7.12-generic)
> [    2.892918] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    2.892971] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    2.893019] r8169 0000:02:00.0: setting latency timer to 64
> [    2.893321] eth0: RTL8101e at 0xf883e000, o.k., XID 34200000 IRQ 221
> [   26.652528] r8169: eth0: link up

another user:
[    0.000000] Linux version 2.6.27-7-generic (buildd@rothera) (gcc version 4.3.2 (Ubuntu 4.3.2-1ubuntu10) ) #1 SMP Fri Oct 24 06:42:44 UTC 2008 (Ubuntu 2.6.
27-7.14-generic)
[    4.803452] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    4.803471] r8169 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    4.803488] r8169 0000:03:00.0: setting latency timer to 64
[    4.804564] r8169 0000:03:00.0: MAC address found in EEPROM: o.k.
[    4.804860] eth0: RTL8101e at 0xf88a8000, o.k., XID 34200000 IRQ 218
[   37.836779] r8169: eth0: link up
[   37.836808] r8169: eth0: link up
[  849.788260] r8169 0000:03:00.0: PME# enabled
[  849.788275] r8169 0000:03:00.0: wake-up capability enabled by ACPI
[  852.564151] r8169 0000:03:00.0: restoring config space at offset 0xf (was 0x100, writing 0x10b)
[  852.564185] r8169 0000:03:00.0: restoring config space at offset 0x6 (was 0x4, writing 0xf0300004)
[  852.564198] r8169 0000:03:00.0: restoring config space at offset 0x4 (was 0x1, writing 0x2001)
[  852.564208] r8169 0000:03:00.0: restoring config space at offset 0x3 (was 0x0, writing 0x10)
[  852.564221] r8169 0000:03:00.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100407)
[  852.564312] r8169 0000:03:00.0: wake-up capability disabled by ACPI
[  852.564319] r8169 0000:03:00.0: PME# disabled
[  855.895177] r8169: eth0: link up

Thanks,
Martin

