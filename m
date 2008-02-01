From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: pktgen should not print info that it is
 spinning
Date: Thu, 31 Jan 2008 17:00:02 -0800 (PST)
Message-ID: <20080131.170002.61912029.davem@davemloft.net>
References: <20080128211635.5907.81831.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	Robert.Olsson@data.slu.se
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764075AbYBAA7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 19:59:41 -0500
In-Reply-To: <20080128211635.5907.81831.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Mon, 28 Jan 2008 13:16:35 -0800

> when using pktgen to send delay packets the module prints repeatedly to the
> kernel log:
> sleeping for X
> sleeping for X
> ...
> 
> This is probably just a debugging item left in and should not be enabled for
> regular use of the module.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Applied, thanks.
