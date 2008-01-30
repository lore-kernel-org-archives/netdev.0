From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pci-skeleton: Misc fixes to build neatly
Date: Wed, 30 Jan 2008 03:49:22 -0500
Message-ID: <47A03A12.60806@garzik.org>
References: <1201157496-20665-1-git-send-email-albcamus@gmail.com> <1201157496-20665-2-git-send-email-albcamus@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jike Song <albcamus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33490 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758009AbYA3ItZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:49:25 -0500
In-Reply-To: <1201157496-20665-2-git-send-email-albcamus@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jike Song wrote:
> The pci-skeleton.c has several problems with compilation, such as missing args
> when calling synchronize_irq(). Fix it.
> 
> Signed-off-by: Jike Song <albcamus@gmail.com>
> ---
>  drivers/net/pci-skeleton.c |   49 ++++++++++++++++++++++---------------------
>  1 files changed, 25 insertions(+), 24 deletions(-)

applied


