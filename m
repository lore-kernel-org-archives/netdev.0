From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Tue, 08 Aug 2006 22:56:53 -0700 (PDT)
Message-ID: <20060808.225653.85409729.davem@davemloft.net>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060809054648.GD17446@2ka.mipt.ru>
	<44D97822.5010007@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, a.p.zijlstra@chello.nl, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24451
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030506AbWHIF4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:56:52 -0400
To: phillips@google.com
In-Reply-To: <44D97822.5010007@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 22:52:34 -0700

> Agreed.  But probably more intrusive than davem would be happy with
> at this point.

I'm much more happy with Evgeniy's network tree allocator, which has a
real design and well thought our long term consequences, than your
work.

