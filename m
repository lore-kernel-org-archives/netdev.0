From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [0/11] pasemi_mac: Patches for 2.6.24
Date: Tue, 2 Oct 2007 16:24:21 -0500
Message-ID: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46597 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754456AbXJBVUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:20:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This series of patches go on top of the previous fixes that were sent
out and picked up.

It's a series of mostly feature-related changes, but also a couple
of bugfixes:

[1/11] pasemi_mac: basic error checking
[2/11] pasemi_mac: fix bug in receive buffer dma mapping
[3/11] pasemi_mac: rework ring management
[4/11] pasemi_mac: implement sg support
[5/11] pasemi_mac: workaround for erratum 5971
[6/11] pasemi_mac: add local skb alignment
[7/11] pasemi_mac: further performance tweaks
[8/11] pasemi_mac: update todo list
[9/11] pasemi_mac: clear out old errors on interface open
[10/11] pasemi_mac: use buffer index pointer in clean_rx()
[11/11] pasemi_mac: enable iommu support


Thanks,

-Olof
