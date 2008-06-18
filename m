From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: 88E8040T pci device id
Date: Tue, 17 Jun 2008 23:26:04 -0400
Message-ID: <4858804C.9040406@pobox.com>
References: <20080614103215.2bceba00@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40534 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756747AbYFRD0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:26:08 -0400
In-Reply-To: <20080614103215.2bceba00@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Missed one pci id for 88E8040T.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/sky2.c	2008-06-14 09:28:04.000000000 -0700
> +++ b/drivers/net/sky2.c	2008-06-14 09:27:34.000000000 -0700
> @@ -118,6 +118,7 @@ static const struct pci_device_id sky2_i
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4352) }, /* 88E8038 */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4354) }, /* 88E8040 */
> +	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4355) }, /* 88E8040T */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4357) }, /* 88E8042 */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x435A) }, /* 88E8048 */

applied


