From: Pavel Roskin <proski@gnu.org>
Subject: Patches from Marcin Juszkiewicz
Date: Fri, 12 May 2006 16:43:30 -0400
Message-ID: <1147466610.8478.41.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:56280 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932227AbWELUno
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 16:43:44 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FeeU5-0004wS-96
	for netdev@vger.kernel.org; Fri, 12 May 2006 16:43:43 -0400
To: netdev@vger.kernel.org, David Gibson <hermes@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

As a co-maintainer of Orinoco driver, I'd like to ask the netdev team
not to apply any patch from Marcin Juszkiewicz touching the Orinoco
driver without my or David's explicit approval.

I'm fine with patches that change e.g. all PCMCIA or PCI drivers across
the board, but not with patches that remove IDs for compatible cards
that were carefully collected over the years.

Any patches for Orinoco drivers that don't come from kernel subsystem
maintainers should be sent to the driver mailing list at
orinoco-devel@lists.sourceforge.net

-- 
Regards,
Pavel Roskin

