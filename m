From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 2/6] Add support for NFC flow classifier
 extensions
Date: Wed, 27 Apr 2011 16:48:38 +0100
Message-ID: <1303919318.2875.7.camel@bwh-desktop>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
	 <20110421204025.23054.3310.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59379 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155Ab1D0Psl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 11:48:41 -0400
In-Reply-To: <20110421204025.23054.3310.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
> This change makes it so that we can add VLAN Ethertype, TCI, and 64bits of
> driver defined data to a network flow classifier allowing us to handle a
> n-tuple flow contained within a network flow classifier.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
[...]

This does not correspond to any version of ethtool.h in kernel history.
I sync'd from current net-next-2.6 instead.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

