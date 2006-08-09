From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
Date: Tue, 08 Aug 2006 22:55:37 -0700 (PDT)
Message-ID: <20060808.225537.112622421.davem@davemloft.net>
References: <20060808193447.1396.59301.sendpatchset@lappy>
	<44D9191E.7080203@garzik.org>
	<44D977D8.5070306@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22659
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030502AbWHIFzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:55:36 -0400
To: phillips@google.com
In-Reply-To: <44D977D8.5070306@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 22:51:20 -0700

> Elaborate please.  Do you think that all drivers should be updated to
> fix the broken blockdev semantics, making NETIF_F_MEMALLOC redundant?
> If so, I trust you will help audit for it?

I think he's saying that he doesn't think your code is yet a
reasonable way to solve the problem, and therefore doesn't belong
upstream.
