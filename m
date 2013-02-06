From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Wed, 6 Feb 2013 16:06:15 +0100
Message-ID: <20130206150615.GA28438@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se>
 <20130206121248.GC10290@order.stressinduktion.org>
 <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se>
 <20130206134950.GD10290@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:57338 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098Ab3BFPJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 10:09:10 -0500
Content-Disposition: inline
In-Reply-To: <20130206134950.GD10290@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch should do the trick. Perhaps you could also take it for a test
> drive? Thanks!

Verified, ff01::/16 from external hosts is blocked.
