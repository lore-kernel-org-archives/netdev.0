From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 13:04:33 +0100
Message-ID: <20120216120433.GA9504@electric-eye.fr.zoreil.com>
References: <20120215163748.GA3998@elliptictech.com> <20120215224122.GA31463@electric-eye.fr.zoreil.com> <20120215233408.GA8389@elliptictech.com> <1329387355.5525.49.camel@linux-s257.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Bowler <nbowler@elliptictech.com>, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: joeyli <jlee@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41499 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab2BPMRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 07:17:07 -0500
Content-Disposition: inline
In-Reply-To: <1329387355.5525.49.camel@linux-s257.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

joeyli <jlee@suse.com> :
[...]
> Did you see any message from r8169 in dmesg said lost firmware file on
> your system?

I can reproduce the problem with the same chipset as Nick (same XID) and
the firmware is loaded.

-- 
Ueimor
