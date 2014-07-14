From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] udp: UDP tunnel enhancements
Date: Mon, 14 Jul 2014 16:12:54 -0700 (PDT)
Message-ID: <20140714.161254.1495587038499399882.davem@davemloft.net>
References: <alpine.DEB.2.02.1407131942580.25072@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757061AbaGNXM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 19:12:57 -0400
In-Reply-To: <alpine.DEB.2.02.1407131942580.25072@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 13 Jul 2014 19:49:29 -0700 (PDT)

> - Add udp_sock_create in new helper module udp_tunnel. Tunnel
>   implementations call this function to create listener UDP ports.
> - Make vxlan and l2tp call udp_sock_create.
> - Move udp_tunnel_segment into udp_offload.c.

Series applied, thank Tom.

Please make the target tree (net-next in this case) explicit in
future submissions.

Thanks again.
