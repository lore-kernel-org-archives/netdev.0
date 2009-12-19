From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gianfar: Fix a filer bug
Date: Fri, 18 Dec 2009 20:38:47 -0800 (PST)
Message-ID: <20091218.203847.15238286.davem@davemloft.net>
References: <1260962098-16815-1-git-send-email-Sandeep.Kumar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	eric.dumazet@gmail.com
To: Sandeep.Kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756009AbZLSEiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:38:46 -0500
In-Reply-To: <1260962098-16815-1-git-send-email-Sandeep.Kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Date: Wed, 16 Dec 2009 16:44:58 +0530

> We need to enable filer whenever we need to use multiple RX
> queues. Also, need to program RIR0 register with the required
> distribution we require, if using RX filer hashing support for
> packet distribution to multiple queues.
> 
> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>

Applied.
