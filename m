From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] pktgen: add full reset functionality
Date: Mon, 10 Nov 2008 16:48:22 -0800 (PST)
Message-ID: <20081110.164822.187707225.davem@davemloft.net>
References: <20081107220140.8528.21932.stgit@gitlost.lost>
	<18709.26688.587966.479504@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, jesse.brandeburg@intel.com,
	robert.olsson@its.uu.se
To: robert@robur.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752111AbYKKAsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 19:48:23 -0500
In-Reply-To: <18709.26688.587966.479504@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@robur.slu.se>
Date: Sat, 8 Nov 2008 11:21:52 +0100

> Jeff Kirsher writes:
>  > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>  > 
>  > While testing pktgen, I found that sometimes my configurations from
>  > previous runs would be left over, particularly when going from a test
>  > with 8 threads down to a test with 4 threads.
>  > 
>  > This adds new functionality to pktgen where you can call
>  > pgset "reset"
 ...
>  > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>  > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>  > CC: Robert Olsson <robert.olsson@its.uu.se>
> 
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied, thanks everyone.
