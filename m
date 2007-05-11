From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] spidernet: remove unnecessary accesses to phy
Date: Fri, 11 May 2007 16:56:28 -0400
Message-ID: <4644D87C.5010903@garzik.org>
References: <20070510171848.GD4452@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42313 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758823AbXEKU4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:56:32 -0400
In-Reply-To: <20070510171848.GD4452@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> 
> Jeff, please apply for 2.6.22; This is a purely janitorial patch.
> 
> (I will have additonal patches for the spidernet in a few days;
> I'm still debugging a rather nasty hang.)
> 
> --linas
> 
> 
> From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
> 
> This patch removes unnecessary accesses to phy registers.
> 
> Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
>  drivers/net/spider_net.c |    8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)

applied.  Please move comments that do not belong in the permanent 
record BELOW the "---".  See Documentation/SubmittingPatches for more info.

	Jeff


