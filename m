From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnx2: Rename MSI-X vectors.
Date: Tue, 16 Dec 2008 20:27:52 -0800 (PST)
Message-ID: <20081216.202752.234981730.davem@davemloft.net>
References: <1229480315-16912-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42696
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750706AbYLQE1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 23:27:51 -0500
In-Reply-To: <1229480315-16912-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 16 Dec 2008 18:18:34 -0800

> Change MSI-X vector names to "ethx-%d".
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
