From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] Remove unused devconf macros
Date: Fri, 07 Dec 2007 23:57:08 -0800 (PST)
Message-ID: <20071207.235708.26548457.davem@davemloft.net>
References: <47591D8B.7000808@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org,
	herbert@gondor.apana.org.au
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753208AbXLHH5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 02:57:38 -0500
In-Reply-To: <47591D8B.7000808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 13:16:43 +0300

> The SNMP_INC_STATS_OFFSET_BH is used only by ICMP6_INC_STATS_OFFSET_BH.
> The ICMP6_INC_STATS_OFFSET_BH is unused.
> 
> Can we drop them?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Sure, applied to net-2.6.25, thanks.
