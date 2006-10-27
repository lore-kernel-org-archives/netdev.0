From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sealevel: uses arp_broken_ops
Date: Thu, 26 Oct 2006 17:15:32 -0700 (PDT)
Message-ID: <20061026.171532.78495570.davem@davemloft.net>
References: <200610251803.15280.toralf.foerster@gmx.de>
	<20061026140809.9b0c8a01.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toralf.foerster@gmx.de, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52922
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946001AbWJ0APq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:15:46 -0400
To: randy.dunlap@oracle.com
In-Reply-To: <20061026140809.9b0c8a01.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 26 Oct 2006 14:08:08 -0700

> Sealevel uses arp_broken_ops so it needs to depend on INET.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
