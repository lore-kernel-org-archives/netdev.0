From: David Miller <davem@davemloft.net>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sun, 13 Jun 2010 17:14:54 -0700 (PDT)
Message-ID: <20100613.171454.71112161.davem@davemloft.net>
References: <4C149147.3080808@intel.com>
	<4C15414E.5090201@intel.com>
	<20100613205922.GA1806@arch.tripp.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yanmin_zhang@linux.intel.com,
	alex.shi@intel.com, tim.c.chen@intel.com
To: markus@trippelsdorf.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41736
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754892Ab0FNAOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 20:14:42 -0400
In-Reply-To: <20100613205922.GA1806@arch.tripp.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "markus@trippelsdorf.de" <markus@trippelsdorf.de>
Date: Sun, 13 Jun 2010 22:59:22 +0200

> On Sun, Jun 13, 2010 at 01:36:30PM -0700, John Fastabend wrote:
>> [PATCH] net: fix deliver_no_wcard regression on loopback device
> 
> This solves the problem here. Thanks.
> 
> Tested-by: Markus Trippelsdorf <markus@trippelsdorf.de>

Thanks for testing.
