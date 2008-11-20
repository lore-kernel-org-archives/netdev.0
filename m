From: David Miller <davem@davemloft.net>
Subject: Re: mv643xx_eth: fix the order of mdiobus_{unregister, free}()
 calls
Date: Thu, 20 Nov 2008 01:40:22 -0800 (PST)
Message-ID: <20081120.014022.214624714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbYKTJqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:46:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Applied to net-2.6
