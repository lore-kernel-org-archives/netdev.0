From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 02/02: nf_log: fix sleeping function called from
 invalid context in seq_show()
Date: Thu, 19 Nov 2009 12:28:15 -0800 (PST)
Message-ID: <20091119.122815.257534442.davem@davemloft.net>
References: <20091119145902.18633.28666.sendpatchset@x2.localnet>
	<20091119145904.18633.11963.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756575AbZKSU16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 15:27:58 -0500
In-Reply-To: <20091119145904.18633.11963.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 19 Nov 2009 15:59:05 +0100 (MET)

> commit 7378396cd172cc058fa62220c6486419046c4e0c
> Author: Wu Fengguang <fengguang.wu@intel.com>
> Date:   Fri Nov 13 09:34:44 2009 +0100
> 
>     netfilter: nf_log: fix sleeping function called from invalid context in seq_show()
...
>     Reported-by: "Yin, Kangkai" <kangkai.yin@intel.com>
>     Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 

Applied.
