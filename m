From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new, Bug, 12969] New: WARNING: at lib/dma-debug.c:539 check_sync+0xe9/0x341() (Not tainted)
Date: Sun, 5 Apr 2009 12:03:33 +0200
Message-ID: <200904051203.33822.mb@bu3sch.de>
References: <20090404.164909.75175000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:54907 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756470AbZDEKFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 06:05:10 -0400
In-Reply-To: <20090404.164909.75175000.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 05 April 2009 01:49:09 David Miller wrote:
> 
> Michael, your b44 patch definitely looks correct.
> 
> Aplied, thanks!

Thanks Dave.

I'll try later if I can reproduce the check_sync warning on my card.

-- 
Greetings, Michael.
