From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/13] cxgb3 - MAC workaround update
Date: Tue, 14 Aug 2007 01:41:09 -0400
Message-ID: <46C14075.6030101@garzik.org>
References: <20070811062933.8022.51781.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46698 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761908AbXHNFlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:41:10 -0400
In-Reply-To: <20070811062933.8022.51781.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Update the MAC workaround to deal with switches that do not
> honor pause frames.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/common.h |    1 +
>  drivers/net/cxgb3/xgmac.c  |   22 +++++++++++-----------
>  2 files changed, 12 insertions(+), 11 deletions(-)

applied


