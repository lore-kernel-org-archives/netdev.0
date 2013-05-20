From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: remove useless VORTEX_PCI() invocations
Date: Mon, 20 May 2013 13:34:40 -0700 (PDT)
Message-ID: <20130520.133440.1608916885248329048.davem@davemloft.net>
References: <201305200017.14069.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756637Ab3ETUen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:34:43 -0400
In-Reply-To: <201305200017.14069.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 20 May 2013 00:17:13 +0400

> It's suboptimal to invoke quite complex VORTEX_PCI() macro every time we want
> to get a 'struct pci_dev *' when we already have it in a variable... 
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
