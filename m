From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 3/6] ethtool: remove strings based approach for
 displaying n-tuple
Date: Wed, 27 Apr 2011 19:12:58 +0100
Message-ID: <1303927978.2875.83.camel@bwh-desktop>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
	 <20110421204030.23054.29242.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20361 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260Ab1D0SNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:13:01 -0400
In-Reply-To: <20110421204030.23054.29242.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
> This change is meant to remove the strings based approach for displaying
> n-tuple filters.  A follow-on patch will replace that functionality with a
> network flow classification based approach that will get the number of
> filters, get their locations, and then request and display them
> individually.
[...]

I'm deferring this until the other patches are updated.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

