From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool 1/2] ethtool.h: implement new MDI-X set defines
Date: Fri, 20 Jul 2012 16:24:09 +0100
Message-ID: <1342797849.2678.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342765524-29711-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56669 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753115Ab2GTPYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 11:24:13 -0400
In-Reply-To: <1342765524-29711-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 23:25 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> These changes implement the kernel side of the interface
> for allowing drivers to set MDI-X state on twisted pair.
> 
> Changes implemented as suggested by Ben Hutchings, thanks Ben!
> 
> see ethtool patches titled:
> ethtool: allow setting MDI-X state
[...]

I don't see the corresponding kernel changes, but I'll hold onto these
for a while in the hope that they show up.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
