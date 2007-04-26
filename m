From: David Miller <davem@davemloft.net>
Subject: Re: [patch 02/15] net/: possible cleanups
Date: Thu, 26 Apr 2007 00:57:55 -0700 (PDT)
Message-ID: <20070426.005755.07455553.davem@davemloft.net>
References: <200704260727.l3Q7RMSV023946@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933409AbXDZH5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:57:47 -0400
In-Reply-To: <200704260727.l3Q7RMSV023946@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:22 -0700

> From: Adrian Bunk <bunk@stusta.de>
> 
> - make the following needlessly global variables static:
>   - core/rtnetlink.c: struct rtnl_msg_handlers[]
>   - netfilter/nf_conntrack_proto.c: struct nf_ct_protos[]
> - make the following needlessly global functions static:
>   - core/rtnetlink.c: rtnl_dump_all()
>   - netlink/af_netlink.c: netlink_queue_skip()
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
