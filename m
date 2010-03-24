From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bnx2: Use proper handler during netpoll.
Date: Tue, 23 Mar 2010 23:20:36 -0700 (PDT)
Message-ID: <20100323.232036.181455205.davem@davemloft.net>
References: <1269385992-18525-1-git-send-email-mchan@broadcom.com>
	<1269385992-18525-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754683Ab0CXGUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:20:12 -0400
In-Reply-To: <1269385992-18525-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 23 Mar 2010 15:13:12 -0800

> Netpoll needs to call the proper handler depending on the IRQ mode
> and the vector.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
