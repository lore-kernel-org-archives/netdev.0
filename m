From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: fix flow control register dump for 82599
 and newer
Date: Sat, 08 Oct 2011 01:56:42 +0100
Message-ID: <1318035402.2771.171.camel@bwh-desktop>
References: <1317867451-23539-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21647 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1JHA4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 20:56:45 -0400
In-Reply-To: <1317867451-23539-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-05 at 19:17 -0700, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Fix reporting of the flow control settings in the register dump for ixgbe.
> Use MFLCN for 82599 and X540 HW instead of FCTRL.
> 
> This patch also adds the ability to check for mac type.
[...]

Applied.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
