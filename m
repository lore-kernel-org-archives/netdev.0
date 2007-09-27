From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net-2.6.24: wrap hard_header_parse
Date: Wed, 26 Sep 2007 22:13:53 -0700 (PDT)
Message-ID: <20070926.221353.94054386.davem@davemloft.net>
References: <20070925.192428.18597166.davem@davemloft.net>
	<20070926172013.0577cd2f@freepuppy.rosehill>
	<20070926172137.5c77baeb@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751843AbXI0FNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 01:13:53 -0400
In-Reply-To: <20070926172137.5c77baeb@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 26 Sep 2007 17:21:37 -0700

> Wrap the hard_header_parse function to simplify next step
> of header_ops conversion.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
