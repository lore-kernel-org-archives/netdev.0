From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
Date: Tue, 08 Aug 2006 15:32:10 -0700 (PDT)
Message-ID: <20060808.153210.52118365.davem@davemloft.net>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060808193355.1396.71047.sendpatchset@lappy>
	<44D8F919.7000006@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	phillips@google.com, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45454
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965054AbWHHWcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 18:32:05 -0400
To: auke-jan.h.kok@intel.com
In-Reply-To: <44D8F919.7000006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Tue, 08 Aug 2006 13:50:33 -0700

> can we really delete these??

netdev_alloc_skb() does it for you
