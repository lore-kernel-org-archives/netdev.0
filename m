From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/19] dmfe: add support for suspend/resume
Date: Tue, 06 Mar 2007 06:21:02 -0500
Message-ID: <45ED4E9E.1050800@garzik.org>
References: <200703061041.l26AfsIK019759@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maximlevitsky@gmail.com,
	val_henson@linux.intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53370 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965853AbXCFLVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:21:04 -0500
In-Reply-To: <200703061041.l26AfsIK019759@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Maxim Levitsky <maximlevitsky@gmail.com>
> 
> This adds support for suspend resume
> 
> [akpm@linux-foundation.org: fix CONFIG_PM=n, coding style]
> Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
> Cc: Valerie Henson <val_henson@linux.intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/tulip/dmfe.c |   52 ++++++++++++++++++++++++++++++++++---
>  1 file changed, 49 insertions(+), 3 deletions(-)

applied 9-10 to #upstream


