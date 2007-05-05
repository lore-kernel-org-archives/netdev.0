From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/11][TG3]: Eliminate the TG3_FLAG_GOT_SERDES_FLOWCTL
 flag.
Date: Sat, 05 May 2007 12:11:38 -0700 (PDT)
Message-ID: <20070505.121138.122942774.davem@davemloft.net>
References: <1178326441.4859.22.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933158AbXEETLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 15:11:51 -0400
In-Reply-To: <1178326441.4859.22.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 04 May 2007 17:54:01 -0700

> [TG3]: Eliminate the TG3_FLAG_GOT_SERDES_FLOWCTL flag.
> 
> This flag does not do anything useful.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

It did do something useful at one point :-)

Applied, thanks.
