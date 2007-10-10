From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] e1000: Simple optimizations in e1000_xmit_frame
Date: Tue, 09 Oct 2007 20:38:51 -0400
Message-ID: <470C1F1B.3090407@garzik.org>
References: <20071005211516.13167.80891.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39056 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbXJJAi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:38:57 -0400
In-Reply-To: <20071005211516.13167.80891.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Some simple optimizations in e1000_xmit_frame.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)

applied 1-2


