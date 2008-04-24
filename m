From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp_generic: use stats from net_device structure
Date: Wed, 23 Apr 2008 18:54:14 -0700 (PDT)
Message-ID: <20080423.185414.200491073.davem@davemloft.net>
References: <funllk$30g$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: paulius.zaleckas@teltonika.lt
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <funllk$30g$1@ger.gmane.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Date: Wed, 23 Apr 2008 18:46:51 +0300

> Use stats which now is in the net_device instead of one declared in
> ppp structure.
> Kill ppp_net_stats function, because by default it is used identical
> internal_stats function from net/core/dev.c
> 
> Signed-of-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Very nice simplification, patch applied.

Thank you!
