From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] be2net: remove netif_stop_queue being
 called before register_netdev.
Date: Tue, 01 Feb 2011 15:42:09 -0800 (PST)
Message-ID: <20110201.154209.179944086.davem@davemloft.net>
References: <20110131232755.GA4691@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307Ab1BAXld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 18:41:33 -0500
In-Reply-To: <20110131232755.GA4691@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Mon, 31 Jan 2011 17:27:55 -0600

> It is illegal to call netif_stop_queue before register_netdev.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied, thanks.
