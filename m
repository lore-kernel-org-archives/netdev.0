From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] cnic: Finetune iSCSI connection reset.
Date: Fri, 26 Feb 2010 02:11:17 -0800 (PST)
Message-ID: <20100226.021117.172531126.davem@davemloft.net>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
	<1267058529-18454-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751481Ab0BZKK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:10:59 -0500
In-Reply-To: <1267058529-18454-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 24 Feb 2010 16:42:05 -0800

> From: Eddie Wai <waie@broadcom.com>
> 
> For bnx2 devices, always send notification to bnx2i to let it initiate
> the cleanup when RST is received.
> 
> For bnx2x devices, add unsolicited RST_COMP handling to start the cleanup.
> 
> Signed-off-by: Eddie Wai <waie@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
