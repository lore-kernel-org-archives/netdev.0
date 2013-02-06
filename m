From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Wed, 6 Feb 2013 16:12:05 +0100
Message-ID: <20130206151205.GA18040@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se> <20130206134950.GD10290@order.stressinduktion.org> <20130206150615.GA28438@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47614 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756488Ab3BFPMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 10:12:07 -0500
Content-Disposition: inline
In-Reply-To: <20130206150615.GA28438@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 04:06:15PM +0100, Erik Hugne wrote:
> > This patch should do the trick. Perhaps you could also take it for a test
> > drive? Thanks!
> 
> Verified, ff01::/16 from external hosts is blocked.

Thanks for testing. Will do proper patch submissions later with whitespace
issue fixed.
