From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 5/6] v4 Add RX packet classification interface
Date: Thu, 28 Apr 2011 00:00:44 +0100
Message-ID: <1303945244.2875.161.camel@bwh-desktop>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
	 <20110421204040.23054.87188.stgit@gitlad.jf.intel.com>
	 <1303927934.2875.82.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47109 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052Ab1D0XAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 19:00:48 -0400
In-Reply-To: <1303927934.2875.82.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-27 at 19:12 +0100, Ben Hutchings wrote:
> On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
[...]
> > +	fprintf(stdout,
> > +		"\tVLAN EtherType: 0x%x mask: 0x%x\n"
> 
> Lower-case 'ethertype', please.
[...]

Sorry, your capitalisation here is correct and the existing uses in
lower-case are wrong.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

