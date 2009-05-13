From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Wed, 13 May 2009 08:11:38 +0200
Message-ID: <20090513061138.GA11106@electric-eye.fr.zoreil.com>
References: <200903041828.49972.m.bueker@berlin.de> <4A06D8D2.4010505@googlemail.com> <1242001754.4093.12.camel@obelisk.thedillows.org> <200905112248.44868.mb@bu3sch.de> <m3eiuufufj.fsf@intrepid.localdomain> <4A09EE13.3020102@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Michael Buesch <mb@bu3sch.de>,
	David Dillow <dave@thedillows.org>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?unknown-8bit?B?QsO8a2Vy?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48711 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbZEMGLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 02:11:45 -0400
Content-Disposition: inline
In-Reply-To: <4A09EE13.3020102@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Riepe <michael.riepe@googlemail.com> :
[...]
> How do lspci and dmesg report the chip? For mine, lspci says it's a
> "RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)" while
> the kernel reports "RTL8168c/8111c at 0xffffc200000f6000,
> 00:1c:c0:b6:1a:4a, XID 3c4000c0".

The XID is more specific than the first kernel report. lspci is less
accurate.

> This reminds me of the early ATA/USB bridges from Genesys Logic... many
> revisions, and each one broken in a different way. :-(

-- 
Ueimor
