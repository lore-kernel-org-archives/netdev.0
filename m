From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qlcnic: remove dead code
Date: Tue, 05 Oct 2010 00:48:50 -0700 (PDT)
Message-ID: <20101005.004850.71585059.davem@davemloft.net>
References: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
	<1286202016-18026-9-git-send-email-amit.salecha@qlogic.com>
	<20101005104430.554c03e6@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com,
	sritej.velaga@qlogic.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752200Ab0JEHsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:48:30 -0400
In-Reply-To: <20101005104430.554c03e6@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 5 Oct 2010 10:44:30 +0900

> This driver has several pieces of dead code (found by running
> make namespacecheck). This patch removes them.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
