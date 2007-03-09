From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] net: deinline some functions
Date: Thu, 08 Mar 2007 20:46:15 -0800 (PST)
Message-ID: <20070308.204615.40144557.davem@davemloft.net>
References: <20070308205214.580772044@linux-foundation.org>
	<20070308205306.161028935@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46794
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992966AbXCIEqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 23:46:15 -0500
In-Reply-To: <20070308205306.161028935@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 08 Mar 2007 12:52:21 -0800

> Several functions are marked inline or forced inline, but it
> would be better to let the compiler decide.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
