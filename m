From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Sun, 22 Mar 2009 22:16:29 +0100
Message-ID: <20090322211629.GA23095@electric-eye.fr.zoreil.com>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903191158.52436.fzu@wemgehoertderstaat.de> <20090319222302.GA1972@electric-eye.fr.zoreil.com> <200903200240.50183.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50901 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752571AbZCVVNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 17:13:25 -0400
Content-Disposition: inline
In-Reply-To: <200903200240.50183.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Wiese <fzu@wemgehoertderstaat.de> :
[...]
> The pc I debugged this on is a UP with no other device active on the used
> int16.

/me wonders...

Does your network adapter support pxe or some boot time operation ?

Btw the XID of the device would be welcome.

-- 
Ueimor
