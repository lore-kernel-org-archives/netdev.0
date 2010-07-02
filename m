From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ll_temac: add error checking to DMA init path
Date: Thu, 01 Jul 2010 22:48:21 -0700 (PDT)
Message-ID: <20100701.224821.266093607.davem@davemloft.net>
References: <20100701093905.GA29132@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, brian.hill@xilinx.com, netdev@vger.kernel.org
To: dkirjanov@hera.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49299
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751887Ab0GBFsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:48:07 -0400
In-Reply-To: <20100701093905.GA29132@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Date: Thu, 1 Jul 2010 09:39:05 +0000

> Add error checking to DMA descriptor rings initialization code.
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied to net-next-2.6
