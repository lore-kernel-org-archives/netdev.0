From: David Miller <davem@davemloft.net>
Subject: Re: a2065 skb_padto cleanups
Date: Wed, 18 Mar 2009 18:18:06 -0700 (PDT)
Message-ID: <20090318.181806.224906255.davem@davemloft.net>
References: <49B89A33.2030207@cosmosbay.com>
	<20090313.133640.130060599.davem@davemloft.net>
	<20090313205216.GA6898@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43388
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753840AbZCSBST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:18:19 -0400
In-Reply-To: <20090313205216.GA6898@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Fri, 13 Mar 2009 16:52:16 -0400

> Remove unnecessary check (skb_padto does the same check)
> Remove unnecessary duplicate variable
> Remove unnecessary clearing of padded part of skb.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Looks good enough to me, applied to net-next-2.6, thanks!
