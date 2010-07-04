From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] bnx2: Always enable MSI-X on 5709.
Date: Sun, 04 Jul 2010 11:44:31 -0700 (PDT)
Message-ID: <20100704.114431.183050044.davem@davemloft.net>
References: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757164Ab0GDSoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 14:44:18 -0400
In-Reply-To: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 3 Jul 2010 23:42:15 -0700

> Minor change to use MSI-X even if there is only one CPU.  This allows
> the CNIC driver to always have a dedicated MSI-X vector to handle
> iSCSI events, instead of sharing the MSI vector.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
