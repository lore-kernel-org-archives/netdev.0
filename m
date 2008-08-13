From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove unnecessary variable in xfrm_output_resume()
Date: Tue, 12 Aug 2008 22:53:06 -0700 (PDT)
Message-ID: <20080812.225306.93454653.davem@davemloft.net>
References: <200808130748.02368.jcd@tribudubois.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jcd@tribudubois.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751848AbYHMFxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 01:53:05 -0400
In-Reply-To: <200808130748.02368.jcd@tribudubois.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Christophe Dubois <jcd@tribudubois.net>
Date: Wed, 13 Aug 2008 07:48:01 +0200

> Small fix removing an unnecessary intermediate variable.
> 
> Signed-off-by: Jean-Christophe DUBOIS  <jcd@tribudubois.net>

I saw your first submission of this patch, you don't need
to send it again.

It's in my backlog, and I have to clear out some more
pressing bugs before I get to these more trivial patches.
