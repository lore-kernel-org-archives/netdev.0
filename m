From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/can/softing: make CAN_SOFTING_CS depend on
 CAN_SOFTING
Date: Mon, 14 Feb 2011 11:44:23 -0800 (PST)
Message-ID: <20110214.114423.183039528.davem@davemloft.net>
References: <20110212111344.GA328@e-circ.dyndns.org>
	<4D56AF22.4070803@oracle.com>
	<20110214075507.GB374@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kurt.van.dijck@eia.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52603
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751515Ab1BNTnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 14:43:47 -0500
In-Reply-To: <20110214075507.GB374@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Date: Mon, 14 Feb 2011 08:55:07 +0100

> The statement 'select CAN_SOFTING' may ignore the dependancies
> for CAN_SOFTING while selecting CAN_SOFTING_CS, as is therefore a bad choice.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks.
