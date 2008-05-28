From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Fix for race =?koi8-r?Q?condit?=
	=?koi8-r?Q?ion_introduced_by_the_temporary_drop_of_the_socket_=9Aloc?=
	=?koi8-r?Q?k?= in skb_splice_bits.
Date: Thu, 29 May 2008 00:05:04 +0400
Message-ID: <20080528200504.GA7349@2ka.mipt.ru>
References: <200805282253.22688.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53243 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893AbYE1UFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 16:05:09 -0400
Content-Disposition: inline
In-Reply-To: <200805282253.22688.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2008 at 10:53:22PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> This patch applies to 2.6.25 and fixes the crashes in tcp_read_sock and 
> skb_splice_bits reported on the mailing list earlier. 

Ack :)

-- 
	Evgeniy Polyakov
