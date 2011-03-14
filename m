From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: Update firmware and version
Date: Mon, 14 Mar 2011 15:00:23 -0700 (PDT)
Message-ID: <20110314.150023.15253728.davem@davemloft.net>
References: <1299628434-4443-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932216Ab1CNV7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:59:45 -0400
In-Reply-To: <1299628434-4443-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 8 Mar 2011 15:53:54 -0800

> Update 5709 mips firmware to 6.2.1a to fix iSCSI performance regression.  There was an unnecessary context read in the fast path affecting performance.
> 
> Update bnx2 to 2.1.6.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
