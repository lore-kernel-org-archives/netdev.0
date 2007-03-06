From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 15/19] 3c59x: Handle pci_enable_device() failure while
 resuming
Date: Tue, 06 Mar 2007 06:11:23 -0500
Message-ID: <45ED4C5B.8060608@garzik.org>
References: <200703061041.l26Afx8Q019778@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmonakhov@sw.ru, dmonakhov@openvz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53207 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965851AbXCFLL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:11:26 -0500
In-Reply-To: <200703061041.l26Afx8Q019778@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Dmitriy Monakhov <dmonakhov@sw.ru>
> 
> Handle pci_enable_device() failure while resuming, we can safely exit here.
> 
> Signed-off-by: Monakhov Dmitriy <dmonakhov@openvz.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/3c59x.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)

applied patches 15-16


