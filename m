From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fixup use of BUS_ID_SIZE
Date: Thu, 08 Jan 2009 10:58:48 -0800 (PST)
Message-ID: <20090108.105848.174722136.davem__40134.085834916$1231442538$gmane$org@davemloft.net>
References: <1231343521-22171-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	afleming@freescale.com, kay.sievers@vrfy.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761632AbZAHS6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:58:46 -0500
In-Reply-To: <1231343521-22171-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Wed,  7 Jan 2009 09:52:01 -0600

> Commit b31a1d8b41513b96e9c7ec2f68c5734cef0b26a4 went back to using
> BUS_ID_SIZE instead of sizeof() as per the larger patch series
> that will remove "char bus_id[20]" from struct device.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

Applied, thanks Kumar.
