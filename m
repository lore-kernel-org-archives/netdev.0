From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net-2.6] ll_temac: fix DMA resources leak
Date: Thu, 08 Jul 2010 23:23:08 -0700 (PDT)
Message-ID: <20100708.232308.242144736.davem@davemloft.net>
References: <20100708135445.GA30923@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, brian.hill@xilinx.com, netdev@vger.kernel.org
To: dkirjanov@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37239
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751337Ab0GIGWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:22:54 -0400
In-Reply-To: <20100708135445.GA30923@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Date: Thu, 8 Jul 2010 13:54:45 +0000

> Fix DMA resources leak.
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied to net-next-2.6, thanks.
