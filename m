From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Sat, 30 Jun 2007 14:48:50 +0200
Message-ID: <200706301448.50541.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <200705012119.48598.peter.missel@onlinehome.de> <20070501200723.GA19212@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49623 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517AbXF3MtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 08:49:01 -0400
In-Reply-To: <20070501200723.GA19212@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Francois!

I have finally gotten round to updating the kernel on this workstation.

It is now on 2.6.21.5 as downloaded from www.kernel.org, built for AMD64.

Unfortunately, the problem is not gone. After suspend-to-disk and resume, link 
speed is 100. Unplugging and replugging the cable does not help. Unloading 
and reloading the driver module brings it back up to 1000.

But now I should have a driver that supports mii_tool, right?

Since I cannot seem to find this tool available for download, could you please 
give me a pointer, or mail me the source? 

Many thanks!

regards,
Peter
