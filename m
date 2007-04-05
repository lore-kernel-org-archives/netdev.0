From: David Miller <davem@davemloft.net>
Subject: Re: [RTNL]: Improve error codes for unsupported operations
Date: Thu, 05 Apr 2007 14:34:09 -0700 (PDT)
Message-ID: <20070405.143409.25475655.davem@davemloft.net>
References: <20070405143402.GY521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767326AbXDEVeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 17:34:11 -0400
In-Reply-To: <20070405143402.GY521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 5 Apr 2007 16:34:02 +0200

> The most common trigger of these errors is that the
> config option hasn't been enable wich would make the
> functionality available. Therefore returning EOPNOTSUPP
> gives a better idea on what is going wrong.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks a lot Thomas.
