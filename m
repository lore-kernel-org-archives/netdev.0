From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen: netfront: ethtool stats fields should be unsigned
 long
Date: Mon, 14 Mar 2011 15:10:29 -0700 (PDT)
Message-ID: <20110314.151029.200378268.davem@davemloft.net>
References: <1299776658-15137-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy@goop.org, bhutchings@solarflare.com
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56600
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757363Ab1CNWJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:09:51 -0400
In-Reply-To: <1299776658-15137-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 10 Mar 2011 17:04:18 +0000

> Fixup the rx_gso_checksum_fixup field added in e0ce4af920eb to be
> unsigned long as suggested by Ben Hutchings in
> <1298919198.2569.14.camel@bwh-desktop>
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Applied, thanks Ian.
