From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] myri10ge: ServerWorks HT2000 PCI id is already defined
 in pci_ids.h
Date: Tue, 31 Oct 2006 20:20:16 -0500
Message-ID: <4547F650.2050302@garzik.org>
References: <45411FD5.3050408@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:27091 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423917AbWKABUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 20:20:18 -0500
To: Brice Goglin <brice@myri.com>
In-Reply-To: <45411FD5.3050408@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> [PATCH] myri10ge: ServerWorks HT2000 PCI id is already defined in pci_ids.h
> 
> No need to keep defining PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE
> in the driver code since it is now defined in pci_ids.h.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

applied


