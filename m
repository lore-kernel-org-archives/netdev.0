From: David Miller <davem@davemloft.net>
Subject: Re: net-next [PATCH 1/1] ipv4: compat_ioctl is local to af_inet.c,
 make it static
Date: Wed, 19 Oct 2011 19:24:57 -0400 (EDT)
Message-ID: <20111019.192457.1533133942407044961.davem@davemloft.net>
References: <20111015192656.GA4066@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1JSX0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 19:26:03 -0400
In-Reply-To: <20111015192656.GA4066@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Oct 2011 13:26:56 -0600

> ipv4: compat_ioctl is local to af_inet.c, make it static
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks.
