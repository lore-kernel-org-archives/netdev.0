From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 1/1] netxen: support for GbE port settings
Date: Tue, 15 Mar 2011 14:55:06 -0700 (PDT)
Message-ID: <20110315.145506.28822679.davem@davemloft.net>
References: <1300172175-16853-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, sony.chacko@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758876Ab1COVy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 17:54:28 -0400
In-Reply-To: <1300172175-16853-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 14 Mar 2011 23:56:15 -0700

> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> o Enable setting speed and auto negotiation parameters for GbE ports.
> o Hardware do not support half duplex setting currently.
> 
> David Miller:
> 	Amit please update your patch to silently reject link setting
> 	attempts that are unsupported by the device.
> 
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied, thank you.
