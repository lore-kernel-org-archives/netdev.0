From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Forcedeth code style cleanup
Date: Sun, 28 Nov 2010 18:07:22 -0800 (PST)
Message-ID: <20101128.180722.226778424.davem@davemloft.net>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: szymon@janc.net.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753283Ab0K2CG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:06:56 -0500
In-Reply-To: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Szymon Janc <szymon@janc.net.pl>
Date: Sat, 27 Nov 2010 19:39:42 +0100

> Hi,
> 
> Following patches make checkpatch less unhappy about forcedeth.c.
> 
> total: 107 errors, 511 warnings, 6222 lines checked
> vs
> total: 12 errors, 467 warnings, 6190 lines checked
> 
> Remaining errors are false positives, remaining warnings are all lines over 80
> characters.

I applied all the patches except patch #5 to net-next-2.6, thanks.
