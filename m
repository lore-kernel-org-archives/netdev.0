From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Wed, 05 Mar 2008 14:19:36 -0800 (PST)
Message-ID: <20080305.141936.07601164.davem@davemloft.net>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
	<Pine.LNX.4.64.0803051355140.31527@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penberg@cs.helsinki.fi, netfilter-devel@vger.kernel.org,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kaber@trash.net
To: clameter@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759118AbYCEWTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 17:19:36 -0500
In-Reply-To: <Pine.LNX.4.64.0803051355140.31527@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 5 Mar 2008 13:56:13 -0800 (PST)

> Acked-by: Christoph Lameter <clameter@sgi.com>
> 
> I guess this should go through the netdev tree?

It should go through Patrick McHardy and the netfilter-devel
folks, who in turn will queue it up to me and -stable if
appropriate.
