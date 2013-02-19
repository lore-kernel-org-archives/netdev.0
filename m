From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 7/7] netfilter: nf_ct_helper: Fix logging for dropped
 packets
Date: Tue, 19 Feb 2013 21:17:49 +0100
Message-ID: <20130219201748.GG3319@localhost>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
 <1361232651-5626-8-git-send-email-pablo@netfilter.org>
 <1361233322.2046.3.camel@joe-AO722>
 <20130219011109.GA6362@localhost>
 <1361237594.2046.16.camel@joe-AO722>
 <20130219015015.GA11869@localhost>
 <1361260267.5920.15.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([174.127.110.175]:26850 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932758Ab3BSUR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 15:17:57 -0500
Content-Disposition: inline
In-Reply-To: <1361260267.5920.15.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2013 at 11:51:07PM -0800, Joe Perches wrote:
> 
> Sorry, I didn't look at the function implementation.
> 
> It doesn't use the var args that follow fmt.
> Two current uses have format and args aren't emitted correctly.

Thanks Joe, will pass this to David asap.

Regards.
