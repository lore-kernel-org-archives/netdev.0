From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] Qlogic qla3xxx driver v2.02.00-k36 for upstream inclusion.
Date: Thu, 20 Jul 2006 13:12:42 +0400
Message-ID: <44BF490A.8040604@tls.msk.ru>
References: <1090CAF73D6FFE4EA45395454C82937B05214A4B@AVEXCH1.qlogic.org> <0BB3E5E7462EEA4295BC02D49691DC0705BC91@AVEXCH1.qlogic.org> <44BE98E5.7060207@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:33623 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S932575AbWGTJMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 05:12:47 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
In-Reply-To: <44BE98E5.7060207@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By the way, should it work with ISP4010 controllers?
Those "expose" network interface card "subdevice" too,
but aren't listed in pci_device_table of the driver,
and after adding the device ID to the driver, it still
does not quite work (I tried, just out of curiosity) -
the NIC on ISP4010 is - it seems - close but not exactly
the same as the driver expects.

Thanks.

/mjt
