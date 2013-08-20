From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Networking problem with 3.11-rc6+
Date: Tue, 20 Aug 2013 23:54:19 +0200
Message-ID: <20130820215419.GA29560@electric-eye.fr.zoreil.com>
References: <5213CB17.5050308@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Chris Clayton <chris2553@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5213CB17.5050308@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Clayton <chris2553@gmail.com> :
[...]
> [    0.207094] acpi PNP0A08:00: ACPI _OSC support notification failed, disabling PCIe ASPM
> [    0.207155] acpi PNP0A08:00: Unable to request _OSC control (_OSC support mask: 0x08)
[...]
> [    5.311191] r8169 0000:07:00.0: can't disable ASPM; OS doesn't have ASPM control
[...]
> [   65.181715] [<f8e38000>] rtl8169_interrupt [r8169]
> [   65.181717] Disabling IRQ #17
> 
> Let me know if I can provide any additional information, although to
> be honest, the boot completed and the KDE desktop started up OK, so
> there may not be much else I can provide unless I find that the
> problem is repeatable.

Please don't hesitate if it happens again, even if it can't be reproduced
on demand.

-- 
Ueimor
