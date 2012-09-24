From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 0/3] VXLAN driver
Date: Mon, 24 Sep 2012 11:43:04 -0700
Message-ID: <20120924184304.727711327@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:44011 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757516Ab2IXSwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 14:52:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements the Virtual eXtensible Local Area Network
tunnel. The code comes from GRE, Bridge, and the OVS Vxlan. The code
has only been tested with the TAP based vxlan 
    https://github.com/upa/vxlan.git

Thanks to Chris for the idea.
