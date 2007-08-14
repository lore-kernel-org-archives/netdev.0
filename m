From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 13/13] cxgb3 - test MSI capabilities
Date: Tue, 14 Aug 2007 01:47:04 -0400
Message-ID: <46C141D8.40805@garzik.org>
References: <20070811063036.8239.27320.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37840 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941911AbXHNFrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:47:06 -0400
In-Reply-To: <20070811063036.8239.27320.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Check that the HW in really in MSI/MSI-X mode
> when it was succesfully enabled.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/cxgb3_main.c |   42 ++++++++++++++++++++++++++++++++++++++++
>  drivers/net/cxgb3/regs.h       |    4 ++++
>  2 files changed, 46 insertions(+), 0 deletions(-)

we really don't need to be adding this to each driver


