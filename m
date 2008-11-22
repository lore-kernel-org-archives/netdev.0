From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/22] qla3xxx: convert to net_device_ops
Date: Fri, 21 Nov 2008 17:37:05 -0800 (PST)
Message-ID: <20081121.173705.73547721.davem@davemloft.net>
References: <20081121232138.343333942@vyatta.com>
	<20081121232240.517617345@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756830AbYKVBhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:37:06 -0500
In-Reply-To: <20081121232240.517617345@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 21 Nov 2008 15:21:57 -0800

> Convert this driver to net_device_ops. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
