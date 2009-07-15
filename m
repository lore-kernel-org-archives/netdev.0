From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: remove unused DECLARE_MAC_BUF
Date: Wed, 15 Jul 2009 11:31:33 -0700 (PDT)
Message-ID: <20090715.113133.153230182.davem@davemloft.net>
References: <1247671139.10754.3.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galak@kernel.crashing.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755845AbZGOSb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 14:31:29 -0400
In-Reply-To: <1247671139.10754.3.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 15 Jul 2009 17:18:59 +0200

> The use of it was converted to %pM, but the variable
> stuck -- remove it now to not cause spurious warnings.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied to net-next-2.6, thanks.
