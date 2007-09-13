From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e100: timer power saving
Date: Wed, 12 Sep 2007 23:45:31 -0400
Message-ID: <46E8B25B.8050902@garzik.org>
References: <20070906185137.30733.99594.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	arjan@linux.intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33109 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753460AbXIMDpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 23:45:36 -0400
In-Reply-To: <20070906185137.30733.99594.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Since E100 timer is 2HZ, use rounding to make timer occur on the
> correct boundary.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

applied


