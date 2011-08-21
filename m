From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Mon, 22 Aug 2011 00:11:40 +0200
Message-ID: <20110821221140.GA20696@electric-eye.fr.zoreil.com>
References: <201108141308.28140.kjun-chen@sambodha.org> <20110821123311.GA20605@electric-eye.fr.zoreil.com> <201108211520.50400.brade@informatik.uni-muenchen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Michael Brade <brade@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36590 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab1HUW30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 18:29:26 -0400
Content-Disposition: inline
In-Reply-To: <201108211520.50400.brade@informatik.uni-muenchen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Brade <brade@informatik.uni-muenchen.de> :
[...]
> r8169 0000:13:00.0: eth0: RTL8168d/8111d at 0xffffc90000c72000, 
> f0:4d:a2:b8:ce:62, XID 083000c0 IRQ 52

RTL_GIGA_MAC_VER_26

> hope that helps,

Yes. There is enough data for me to reproduce the bug with the
exact same chipset.

-- 
Ueimor
