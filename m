From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bfin_mac: use the newer CLKBUFOE bit name via
 asm/dpmc.h
Date: Tue, 19 Jan 2010 02:00:57 -0800 (PST)
Message-ID: <20100119.020057.124459621.davem@davemloft.net>
References: <1263885252-23130-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756541Ab0ASKAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:00:47 -0500
In-Reply-To: <1263885252-23130-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Tue, 19 Jan 2010 02:14:12 -0500

> This driver tweaks VR_CTL, so pull in the header for the bit defines.
> Also switch to the new define name as the old one has gone away.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
> note: this fixes a build error in current 2.6.33-rcX

Applied, thanks.
