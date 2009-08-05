From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] Add IDs for 3C905B-TX Fast Etherlink XL PCI
Date: Wed, 5 Aug 2009 16:41:00 +0200
Message-ID: <20090805144100.GA9346@skl-net.de>
References: <1249481499-9560-1-git-send-email-pterjan@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pascal Terjan <pterjan@mandriva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from systemlinux.org ([83.151.29.59]:52446 "EHLO m18s25.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934618AbZHEPIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 11:08:01 -0400
Content-Disposition: inline
In-Reply-To: <1249481499-9560-1-git-send-email-pterjan@mandriva.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2009 at 04:11:39PM +0200, Pascal Terjan wrote:
> We found this old card which was not supported, and physically
> looks similar to the other 3C905B we have (9055).
> 
> After adding the IDs it seems to work fine (MII report, dhcp, scp, ...)

The patch looks sane.
Btw. you should add a Signed-off-by line to your patches.

Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
