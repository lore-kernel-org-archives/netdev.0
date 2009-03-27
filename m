From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 3/5] cxgb3: use resource_size_t for mmio
 declarations
Date: Fri, 27 Mar 2009 00:53:10 -0700 (PDT)
Message-ID: <20090327.005310.57231679.davem@davemloft.net>
References: <20090327023909.32137.93884.stgit@speedy5>
	<20090327023919.32137.81488.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36369
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755677AbZC0HxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:53:23 -0400
In-Reply-To: <20090327023919.32137.81488.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Thu, 26 Mar 2009 19:39:19 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Use resource_size_t to declare mmio start and len variables.
> Print PEX error register after EEH resumed.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
