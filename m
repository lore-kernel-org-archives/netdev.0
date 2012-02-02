From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bna: Implement ethtool flash_device entry point.
Date: Thu, 2 Feb 2012 01:29:54 +0000
Message-ID: <1328146194.2541.20.camel@bwh-desktop>
References: <1328144561-25067-1-git-send-email-kgudipat@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@brocade.com>
To: <kgudipat@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49159 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753189Ab2BBB36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 20:29:58 -0500
In-Reply-To: <1328144561-25067-1-git-send-email-kgudipat@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-01 at 17:02 -0800, kgudipat@brocade.com wrote:
> From: Krishna Gudipati <kgudipat@brocade.com>
> 
> Incorporated review comments from Ben Hutchings.
> 
> Change details:
> 	- Implement ethtool flash_device() entry point to write the
> 	  firmware image to the flash firmware partition.
> 
> Signed-off-by: Krishna Gudipati <kgudipat@brocade.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
