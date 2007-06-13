From: linux@horizon.com
Subject: Re: IC Plus Corp IC Plus IP1000
Date: 13 Jun 2007 14:24:02 -0400
Message-ID: <20070613182402.15983.qmail@science.horizon.com>
References: <20070613015721.31814.qmail@science.horizon.com>
Cc: linux@horizon.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:19495 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759225AbXFMSb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 14:31:26 -0400
In-Reply-To: <20070613015721.31814.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Use the 'sundance' driver that's been in the kernel for quite a while.

Er... that driver specifically does not list the IP1000's PCI device ID
(13f0:1023), nor does it support anything over 100 Mbit/s.

Are you *quite* sure that adding 13f0:1023 to the sundance_pci_tbl is
all that's required?
