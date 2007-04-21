From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Move sk_setup_caps out of line
Date: Fri, 20 Apr 2007 17:12:56 -0700 (PDT)
Message-ID: <20070420.171256.133433686.davem@davemloft.net>
References: <200704051246.21134.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752937AbXDUAMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:12:53 -0400
In-Reply-To: <200704051246.21134.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 5 Apr 2007 12:46:21 +0200

> It is far too large to be an inline and not in any hot paths.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

Also applied, thanks Andi.
