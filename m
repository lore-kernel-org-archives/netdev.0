From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 00/19] CALIPSO Implementation
Date: Tue, 21 Jun 2016 05:39:28 -0400 (EDT)
Message-ID: <20160621.053928.1340819307282355897.davem@davemloft.net>
References: <1466429819-12707-1-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, pmoore@redhat.com
To: huw@codeweavers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbcFUJlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 05:41:55 -0400
In-Reply-To: <1466429819-12707-1-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huw Davies <huw@codeweavers.com>
Date: Mon, 20 Jun 2016 14:36:40 +0100

> This patch series implements RFC 5570 - Common Architecture Label IPv6
> Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
> on IPv6 packets using a hop-by-hop option.  CALIPSO is very similar to
> its IPv4 cousin CIPSO and much of this series is based on that code.
> 
> To use this you'll need some patches to netlabel-tools that are
> available on the 'working-calipso-v3' branch at:
> https://github.com/netlabel/netlabel_tools .  The protocol has
> changed very slightly from the v2 patches, so please update to the
> latest if you haven't already done so.
> 
> This implementation has been tested against the CALIPSO implementation
> of Solaris Trusted Extensions.
> 
> This patch series is based off v4.6.
 ...

What tree do you expect to integrate this?
