From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: pull request: wireless-2.6 2008-09-24
Date: Thu, 25 Sep 2008 13:47:02 +0800
Message-ID: <1222321622.2510.455.camel@debian.sh.intel.com>
References: <20080924231720.GD3639@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26195 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750841AbYIYFrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 01:47:41 -0400
In-Reply-To: <20080924231720.GD3639@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-09-24 at 17:17 -0600, John W. Linville wrote:
> Dave,
> 
> One more for 2.6.27 -- a fix for a possible interrupt storm.  There is
> even a link in the commit log to a youtube video of the storm in
> progress. :-)
> 
> Let me know if there are problems!

Can you also add this one? It doesn't panic the kernel when a frame from
firmware is invalid.

http://marc.info/?l=linux-wireless&m=122219037706528&w=2

Thanks,
-yi

