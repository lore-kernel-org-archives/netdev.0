From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: instant crash if receiving packet larger than MTU
Date: Tue, 17 Feb 2009 20:37:49 +0100
Message-ID: <20090217193749.GA12921@electric-eye.fr.zoreil.com>
References: <4996E054.20905@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57051 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbZBQTf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 14:35:27 -0500
Content-Disposition: inline
In-Reply-To: <4996E054.20905@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Tokarev <mjt@tls.msk.ru> :
> I played with jumbo frames today at home on two
> machines with built-in r8169 NICs.  And discovered
> that, after enabling larger packets on one machine,
> it's sufficient to send SINGLE packet to immediately,
> instantly crash the other machine.

Which size did you use and how did it crash (dead keyboard leds
without any message in the console ?) ?

-- 
Ueimor
