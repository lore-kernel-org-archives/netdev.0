From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 9/16][BNX2]: Put MII register offsets in the bnx2
 struct.
Date: Thu, 03 May 2007 13:23:00 -0700 (PDT)
Message-ID: <20070503.132300.46194339.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<1178177406.4909.72.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754426AbXECUXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:23:00 -0400
In-Reply-To: <1178177406.4909.72.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 00:30:06 -0700

> [BNX2]: Put MII register offsets in the bnx2 struct.
> 
> The 5709 Serdes device uses non-standard MII register offsets.  This
> re-structuring will make it easier to support 5709 Serdes.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
