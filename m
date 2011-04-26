From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] iproute2: tc add mqprio qdisc support
Date: Tue, 26 Apr 2011 20:18:12 +0100
Message-ID: <1303845492.2850.7.camel@bwh-desktop>
References: <20110426185331.12236.41211.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56438 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab1DZTSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:18:15 -0400
In-Reply-To: <20110426185331.12236.41211.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-26 at 11:53 -0700, John Fastabend wrote:
> Add mqprio qdisc support. Output matches the following,
[...]

Stephen already applied the previous version of this, so you'll need to
provide an incremental patch to change the argument parsing.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

