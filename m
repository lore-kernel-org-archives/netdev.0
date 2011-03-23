From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: remove mask for Auto in advertise section
Date: Wed, 23 Mar 2011 15:56:58 +0000
Message-ID: <1300895818.2638.2.camel@bwh-desktop>
References: <1299310021-29027-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18785 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756470Ab1CWP5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 11:57:01 -0400
In-Reply-To: <1299310021-29027-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-04 at 23:27 -0800, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> The mask for Auto in the advertise section is incorrect for any interface
> that supports speeds > 1000Mbps. Since the description already states that
> the mask can be a combination of the supported values it's probably better
> to just remove it. 'Auto' was misleading anyway.
[...]

Applied.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

