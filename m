From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 0/6] Network flow classifier
Date: Thu, 21 Apr 2011 21:51:33 +0100
Message-ID: <1303419093.3165.57.camel@bwh-desktop>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18447 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab1DUUvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 16:51:36 -0400
In-Reply-To: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
> The following patches are meant to add support for the network flow classifier
> interface built into the ethtool_rxnfc.
> 
> Once this has been accepted I plan to submit the kernel portion to Jeff
> Kirsher as it is almost all ixgbe code changes with the exception of the
> removal of support for ethtool_get_rx_ntuple from the kernel.
[...]

This is the start of a 4-way weekend in the UK, so don't be surprised if
I take a while to review these changes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

