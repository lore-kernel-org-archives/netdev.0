From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: slay double assignment
Date: Sun, 24 Oct 2010 16:26:11 -0700 (PDT)
Message-ID: <20101024.162611.02282476.davem@davemloft.net>
References: <20101022180003.GO8332@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org
To: kyle@mcmartin.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750996Ab0JXXZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 19:25:48 -0400
In-Reply-To: <20101022180003.GO8332@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@mcmartin.ca>
Date: Fri, 22 Oct 2010 14:00:03 -0400

> Noticed this while building Fedora today... It's been
> there since around 2007, so I guess a new gcc must be catching
> these.
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>

This patch doesn't apply.
