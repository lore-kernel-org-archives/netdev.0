From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 4/6][SOCK][NETNS]: Register sockstat(6)
 files in each net.
Date: Mon, 31 Mar 2008 20:19:18 -0700 (PDT)
Message-ID: <20080331.201918.251682004.davem@davemloft.net>
References: <47F0D665.9010807@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47818
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753476AbYDADTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 23:19:17 -0400
In-Reply-To: <47F0D665.9010807@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 31 Mar 2008 16:17:41 +0400

> Currently they live in init_net only, but now almost all the info
> they can provide is available per-net.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
