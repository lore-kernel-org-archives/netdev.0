From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NET-NEXT] net: Kill unuseful net/TUNABLE doc in kernel
 source
Date: Fri, 24 Jun 2011 17:42:30 -0700 (PDT)
Message-ID: <20110624.174230.348363465031302355.davem@davemloft.net>
References: <4E04428C.9080703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab1FYAme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 20:42:34 -0400
In-Reply-To: <4E04428C.9080703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 24 Jun 2011 15:53:48 +0800

> File net/TUNABLE has never be updated since git age.
> 
> For some tunable parameters which user can control with proc file-system,
> They are all in ip-sysctl.txt doc.
> 
> For tunable parameters that only at compile time, no meaning to note them.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied, thanks.
