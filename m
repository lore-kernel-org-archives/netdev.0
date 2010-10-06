From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: normalize frag_list usage
Date: Tue, 05 Oct 2010 20:08:17 -0700 (PDT)
Message-ID: <20101005.200817.226767934.davem@davemloft.net>
References: <4CAA1722.7070405@intel.com>
	<20101004.113258.212671454.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755141Ab0JFDH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:07:56 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Tue, 5 Oct 2010 15:45:32 -0700

> The patch below is kind of what I had in mind for a way to do RSC
> and maintain the pointer scheme you are looking for.  Consider this
> patch an RFC for now since I based this off of Jeff's internal
> testing tree and so it would need some modification to apply cleanly
> to net-next.

Thanks a lot for doing this work Alex.

I'll take a look and give you some feedback soon.
