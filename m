From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.16.13 e1000 reports incorrect PCI-X bus speed?
Date: Fri, 12 May 2006 15:26:02 -0700
Message-ID: <44650B7A.70209@candelatech.com>
References: <4464FB01.6070206@candelatech.com> <4464FF41.7060000@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:36744 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932263AbWELW0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 18:26:11 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <4464FF41.7060000@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:

> obviously 120 is missing, but PCI-E speeds are also missing (2500gbps). The
> output of the e1000 module is correct.

Any idea why 120Mhz is used instead of 133?  It doesn't
seem to matter in my performance tests, but I am curious...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

