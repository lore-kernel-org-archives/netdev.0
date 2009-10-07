From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dcb: data center bridging ops should be r/o
Date: Wed, 07 Oct 2009 01:30:07 -0700 (PDT)
Message-ID: <20091007.013007.127234139.davem@davemloft.net>
References: <20091005090103.0340ef29@s6510>
	<1254773298.2667.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@gmail.com, netdev@vger.kernel.org,
	e1000-devel@lists.sf.net
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933990AbZJGIaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:30:13 -0400
In-Reply-To: <1254773298.2667.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 05 Oct 2009 13:08:18 -0700

> On Mon, 2009-10-05 at 09:01 -0700, Stephen Hemminger wrote:
>> The data center bridging ops structure can be const
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
> 
> Thanks Stephen, that was an oversight.
> 
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied.
