From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
Date: Tue, 08 Aug 2006 15:42:25 -0700
Message-ID: <44D91351.2020702@intel.com>
References: <20060808193325.1396.58813.sendpatchset@lappy>	<20060808193355.1396.71047.sendpatchset@lappy>	<44D8F919.7000006@intel.com> <20060808.153210.52118365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	phillips@google.com, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24215 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S965064AbWHHWnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 18:43:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.153210.52118365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> Date: Tue, 08 Aug 2006 13:50:33 -0700
> 
>> can we really delete these??
> 
> netdev_alloc_skb() does it for you

yeah I didn't spot that patch #2 in that series introduces that code - my bad. 
Thanks.

Auke
