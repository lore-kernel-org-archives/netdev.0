From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 9391] New: Netgear GA320T(tg3) strange errors
 and non-workingness
Date: Fri, 16 Nov 2007 20:46:51 +0100
Message-ID: <473DF3AB.7020102@o2.pl>
References: <20071115181809.592a110c.akpm@linux-foundation.org>	 <20071116083007.GA2124@ff.dom.local> <cccedfc60711160608j1ff89979uf7c1f122dd050adc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mchan@broadcom.com, Andrew Morton <akpm@linux-foundation.org>
To: Jon Nelson <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:44201 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763156AbXKPToS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 14:44:18 -0500
In-Reply-To: <cccedfc60711160608j1ff89979uf7c1f122dd050adc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Nelson wrote, On 11/16/2007 03:08 PM:

...
> The lspci is exactly as it was output. The dmesg is shortened only
> slightly. The kernel is the latest available for openSUSE 10.3. No MSI
> because this is an Athlon XP (read: 32bit, single core, regular old
> 33MHz, 32bit PCI).
> 
> The interrupts look *exactly* the same with or without noapic. This
> board doesn't have apic as far as I know. It's an ECS K7S5A I think.
> 
> Does that help?


Yes. You might be right with these interrupts. But, dmesg doesn't
really show enough. Try to paste this all, at least until the first
WATCHDOG time out and card reset.

Thanks,
Jarek P.
