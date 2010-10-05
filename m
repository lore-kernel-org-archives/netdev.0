From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: make __ipv6_isatap_ifid static
Date: Tue, 05 Oct 2010 00:49:12 -0700 (PDT)
Message-ID: <20101005.004912.173849764.davem@davemloft.net>
References: <20101005151753.363121b8@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54765
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755209Ab0JEHsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:48:51 -0400
In-Reply-To: <20101005151753.363121b8@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 5 Oct 2010 15:17:53 +0900

> Another exported symbol only used in one file
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
