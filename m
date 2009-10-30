From: David Miller <davem@davemloft.net>
Subject: Re: [patch]convert kaweth to use usb_reset_configuration()
Date: Thu, 29 Oct 2009 23:07:04 -0700 (PDT)
Message-ID: <20091029.230704.156188825.davem@davemloft.net>
References: <200910291607.12382.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sarah.a.sharp@linux.intel.com, netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58420
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755662AbZJ3GGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 02:06:40 -0400
In-Reply-To: <200910291607.12382.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 29 Oct 2009 16:07:12 +0100

> For USB 3.0 it is necessary that all drivers use the standard
> API to reset a configuration. This removes a home-grown
> implementation.
> 
> Signed-off-by: Oliver Neukum <oliver@neukum.org>
> 
> Hi David,
> 
> please take this for the next merge window.

Applied to net-next-2.6, thanks Oliver.
