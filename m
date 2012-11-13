From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 0/4] New Bridge security features
Date: Tue, 13 Nov 2012 09:53:04 -0800
Message-ID: <20121113175304.628996029@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:36668 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754783Ab2KMR56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:57:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New bridge API's and security features for protecting
Spanning Tree Protocol.  For more info, see KVM forum talk
  http://www.slideshare.net/shemminger/new-bridge
and BPDU guard explanation here:
  http://blog.ipexpert.com/2010/12/06/bpdu-filter-and-bpdu-guard/
