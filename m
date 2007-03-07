From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/4] myri10ge minor updates
Date: Wed, 07 Mar 2007 19:58:52 +0100
Message-ID: <45EF0B6C.9070005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1876 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965502AbXCGTBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 14:01:04 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

4 small updates of myri10ge for 2.6.21 will follow this mail:
1) fix error checking and return value in myri10ge_allocate_rings
2) use pci_map_page to prepare the dmatest buffer
3) prevent 4k rdma on SGI TIOCE chipset
4) add a wc_enabled flag to myri10ge_priv

Thanks,

Brice

