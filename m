From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] SCTP: port randomization
Date: Wed, 10 Oct 2007 17:43:44 -0700 (PDT)
Message-ID: <20071010.174344.03979935.davem@davemloft.net>
References: <20071011000020.907277335@linux-foundation.org>
	<20071011000042.624753621@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756661AbXJKAnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 20:43:41 -0400
In-Reply-To: <20071011000042.624753621@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 10 Oct 2007 17:00:21 -0700

> Add port randomization rather than a simple fixed rover
> for use with SCTP.  This makes it act similar to TCP, UDP, DCCP
> when allocating ports.
> 
> No longer need port_alloc_lock as well (suggestion by Brian Haley).
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
