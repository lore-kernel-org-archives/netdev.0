From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Wed, 13 May 2009 21:34:12 +0200
Message-ID: <m33ab894qz.fsf@intrepid.localdomain>
References: <200903041828.49972.m.bueker@berlin.de>
	<4A06D8D2.4010505@googlemail.com>
	<1242001754.4093.12.camel@obelisk.thedillows.org>
	<200905112248.44868.mb@bu3sch.de>
	<m3eiuufufj.fsf@intrepid.localdomain>
	<4A09EE13.3020102@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, David Dillow <dave@thedillows.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?iso-8859-2?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752979AbZEMTeb@vger.kernel.org>
In-Reply-To: <4A09EE13.3020102@googlemail.com> (Michael Riepe's message of "Tue\, 12 May 2009 23\:45\:55 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Riepe <michael.riepe@googlemail.com> writes:

> How do lspci and dmesg report the chip? For mine, lspci says it's a
> "RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)" while
> the kernel reports "RTL8168c/8111c at 0xffffc200000f6000,
> 00:1c:c0:b6:1a:4a, XID 3c4000c0".

Sure, that's the same chip I think.

> This reminds me of the early ATA/USB bridges from Genesys Logic... many
> revisions, and each one broken in a different way. :-(

This seems like the same revision. I'm not very convinced it's the RTL
chip which is buggy.
-- 
Krzysztof Halasa
