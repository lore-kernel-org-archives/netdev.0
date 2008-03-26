From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2.6.26] Fix the data buffer stashing amount
Date: Wed, 26 Mar 2008 00:46:03 -0400
Message-ID: <47E9D50B.90909@garzik.org>
References: <1206374009-1292-1-git-send-email-afleming@freescale.com> <1206374009-1292-2-git-send-email-afleming@freescale.com> <1206374009-1292-3-git-send-email-afleming@freescale.com> <1206374009-1292-4-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dai Haruki <dai.haruki@freescale.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38510 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbYCZEqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:46:05 -0400
In-Reply-To: <1206374009-1292-4-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> From: Dai Haruki <dai.haruki@freescale.com>
> 
> - Buffer stashing parameter change to 96 from 64 in order to cover the Layer 4 header.
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> ---
>  drivers/net/gianfar.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied all four patches

Please include a "gianfar: " prefix or similar in your subject line.

After the bracketed info is stripped by automated tools, we are only 
left with a vague "Fix the data buffer stashing amount" one-line 
description of your change, with no clue as to what area of the kernel 
this change applies to


