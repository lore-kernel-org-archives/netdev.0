From: David Miller <davem@davemloft.net>
Subject: Re: [RFC: net-2.6.20 patch] remove unused exports
Date: Wed, 07 Mar 2007 14:48:23 -0800 (PST)
Message-ID: <20070307.144823.08321622.davem@davemloft.net>
References: <20070307224059.GA3441@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, mpm@selenic.com,
	linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47388
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992734AbXCGWsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 17:48:24 -0500
In-Reply-To: <20070307224059.GA3441@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Wed, 7 Mar 2007 23:40:59 +0100

> This patch removes the following not or no longer used exports:
> - drivers/char/random.c: secure_tcp_sequence_number
> - net/dccp/options.c: sysctl_dccp_feat_sequence_window
> - net/netlink/af_netlink.c: netlink_set_err
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied to net-2.6.22, thanks Adrian.
