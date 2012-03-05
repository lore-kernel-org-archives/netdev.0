From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 net-next] tg3: Add memory barriers to sync BD data
Date: Sun, 04 Mar 2012 20:39:45 -0500 (EST)
Message-ID: <20120304.203945.486683955707922922.davem@davemloft.net>
References: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
	<1330908495-3758-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190Ab2CEBjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:39:47 -0500
In-Reply-To: <1330908495-3758-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 4 Mar 2012 16:48:14 -0800

> for weak memory model architectures to ensure that the chip will DMA
> valid BD data.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
