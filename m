From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 12/13] cxgb3 - log and clear PEX errors
Date: Tue, 14 Aug 2007 01:46:51 -0400
Message-ID: <46C141CB.8050305@garzik.org>
References: <20070811063031.8221.70512.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37835 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S942619AbXHNFqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:46:53 -0400
In-Reply-To: <20070811063031.8221.70512.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Clear pciE PEX errors late at module load time.
> Log details when PEX errors occur.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/t3_hw.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)

ACK 10-12


