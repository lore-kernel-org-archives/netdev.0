From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/02] net/ipv4: Add support for new tunnel
 type VTI.
Date: Thu, 28 Jun 2012 18:01:42 -0700 (PDT)
Message-ID: <20120628.180142.1052122232579504478.davem@davemloft.net>
References: <20120629005214.GA4477@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saurabh.mohan@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab2F2BBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 21:01:43 -0400
In-Reply-To: <20120629005214.GA4477@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh <saurabh.mohan@vyatta.com>
Date: Thu, 28 Jun 2012 17:52:14 -0700

> Virtual tunnel interface is a way to represent policy based IPsec tunnels as virtual interfaces in linux. This is similar to Cisco's VTI (virtual tunnel interface) and Juniper's representaion of secure tunnel (st.xx). The advantage of representing an IPsec tunnel as an interface is that it is possible to plug Ipsec tunnels into the routing protocol infrastructure of a router. Therefore it becomes possible to influence the packet path by toggling the link state of the tunnel or based on routing metrics.

Please format your text paragraphs for ~80 character lines, this is a
single 500+ character line in my email client and painful to read.
