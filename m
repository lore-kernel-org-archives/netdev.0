From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: [PATCH] Qlogic qla3xxx driver v2.02.00-k36 for upstream inclusion.
Date: Thu, 20 Jul 2006 07:32:22 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07223E4E@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:53817 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S932562AbWGTOcU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 10:32:20 -0400
Content-class: urn:content-classes:message
To: "Michael Tokarev" <mjt@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

qla3xxx driver  does not support ISP4010.

> -----Original Message-----
> From: Michael Tokarev [mailto:mjt@tls.msk.ru] 
> Sent: Thursday, July 20, 2006 2:13 AM
> To: Ron Mercer
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH] Qlogic qla3xxx driver v2.02.00-k36 for 
> upstream inclusion.
> 
> By the way, should it work with ISP4010 controllers?
> Those "expose" network interface card "subdevice" too, but 
> aren't listed in pci_device_table of the driver, and after 
> adding the device ID to the driver, it still does not quite 
> work (I tried, just out of curiosity) - the NIC on ISP4010 is 
> - it seems - close but not exactly the same as the driver expects.
> 
> Thanks.
> 
> /mjt
> 
