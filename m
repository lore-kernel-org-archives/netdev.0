From: David Miller <davem@davemloft.net>
Subject: Re: Fix net-2.6.25 compiler error
Date: Wed, 14 Nov 2007 01:59:57 -0800 (PST)
Message-ID: <20071114.015957.176250590.davem@davemloft.net>
References: <473AC575.7020306@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756310AbXKNJ75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:59:57 -0500
In-Reply-To: <473AC575.7020306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 14 Nov 2007 10:52:53 +0100

> Fix a missed NF_IP6_LOCAL_OUT conversion.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, my allmodconfig test build just hit this one too.

Thanks again!
