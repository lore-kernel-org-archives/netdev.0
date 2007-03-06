From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 17/19] sk98lin: handle pci_enable_device() return value
 in skge_resume()
Date: Tue, 06 Mar 2007 06:21:11 -0500
Message-ID: <45ED4EA7.70909@garzik.org>
References: <200703061042.l26Ag1Y3019784@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmonakhov@openvz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53376 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965861AbXCFLVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:21:13 -0500
In-Reply-To: <200703061042.l26Ag1Y3019784@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Dmitriy Monakhov <dmonakhov@openvz.org>
> 
> Signed-off-by: Monakhov Dmitriy <dmonakhov@openvz.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sk98lin/skge.c |   20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)

applied


