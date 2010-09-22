From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 3/3] sundance: Use dev_kfree_skb_any() helper
Date: Tue, 21 Sep 2010 18:06:44 -0700 (PDT)
Message-ID: <20100921.180644.183052321.davem@davemloft.net>
References: <20100921085749.GA21902@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dkirjanov@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54175
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755752Ab0IVBGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:06:24 -0400
In-Reply-To: <20100921085749.GA21902@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@kernel.org>
Date: Tue, 21 Sep 2010 08:57:49 +0000

> Use dev_kfree_skb_any() helper to free the skb
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied.
