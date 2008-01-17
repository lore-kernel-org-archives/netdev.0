From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: [RFT] sky2: wake-on-lan configuration issues
Date: Thu, 17 Jan 2008 22:08:04 +0100
Message-ID: <20080117210804.GA2372@thinkpad.home.local>
References: <bug-9721-10286@http.bugzilla.kernel.org/> <478A743C.9050405@yahoo.de> <20080113125708.070b4843.akpm@linux-foundation.org> <200801132227.59229.rjw@sisk.pl> <478A965E.8070306@yahoo.de> <20080114101439.72304b92@deepthought> <478BCE98.5030709@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:43270 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbYAQVfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 16:35:31 -0500
Received: from thinkpad.home.local (port-212-202-36-141.dynamic.qsc.de [212.202.36.141])
	by eazy.amigager.de (Postfix) with ESMTP id A0ACCC8C5D7
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 22:08:12 +0100 (CET)
Received: from scorpion by thinkpad.home.local with local (Exim 4.68)
	(envelope-from <tino.keitel@tikei.de>)
	id 1JFby0-0000g1-VN
	for netdev@vger.kernel.org; Thu, 17 Jan 2008 22:08:05 +0100
Content-Disposition: inline
In-Reply-To: <478BCE98.5030709@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I tried 2.6.24-rc8 on my Mac mini Core Duo and noticed that WOL didn't
work anymore, whereas I never had a WOL failure with 2.6.23. The above
patch fixes WOL with 2.6.24-rc8 for me.

Thanks for tracking it down even before I was hit by this regression.
:-)

Regards,
Tino
