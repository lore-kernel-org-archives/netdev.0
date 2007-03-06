From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 14/19] drivers/net/vioc/vioc_driver.c: replace pci_module_init
 with pci_register_driver
Date: Tue, 06 Mar 2007 06:22:39 -0500
Message-ID: <45ED4EFF.4040502@garzik.org>
References: <200703061041.l26AfwFn019774@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ricknu-0@student.ltu.se,
	driver-support@fabric7.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53425 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934080AbXCFLWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:22:43 -0500
In-Reply-To: <200703061041.l26AfwFn019774@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Richard Knutsson <ricknu-0@student.ltu.se>
> 
> Replace pci_module_init with pci_register_driver
> 
> Signed-off-by: Richard Knutson <ricknu-0@student.ltu.se>
> Cc: <support@fabric7.com>
> Cc: <driver-support@fabric7.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/vioc/vioc_driver.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

applied


