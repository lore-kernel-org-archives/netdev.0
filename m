From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Wed, 6 Feb 2013 17:54:15 +0100
Message-ID: <20130206165415.GB19537@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47886 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab3BFQyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:54:17 -0500
Content-Disposition: inline
In-Reply-To: <5112759E.90104@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2013 at 12:24:14AM +0900, YOSHIFUJI Hideaki wrote:
> NAK.  I think we should select routes via loopback device here.

Will try your idea, thanks.
