From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] sky2: status polling loop (post merge)
Date: Thu, 11 Oct 2007 18:31:46 -0700 (PDT)
Message-ID: <20071011.183146.39159626.davem@davemloft.net>
References: <20071012012124.965282742@linux-foundation.org>
	<20071011.182358.21595252.davem@davemloft.net>
	<20071011182921.1b20505c@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753816AbXJLBbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:31:43 -0400
In-Reply-To: <20071011182921.1b20505c@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 11 Oct 2007 18:29:21 -0700

> Handle the corner case where budget is exhausted correctly.
> And save unnecessary read of index register.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.

You can submit the rest later, I deleted them since they
likely depend upon line offsets and other things in this
patch.
