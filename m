From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/18] Kill off NLMSG_NEW and NLMSG_PUT
Date: Wed, 27 Jun 2012 03:10:42 -0400
Message-ID: <20120627071042.GD31808@canuck.infradead.org>
References: <20120626.220155.1298849942906073647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:57337 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756155Ab2F0HKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 03:10:45 -0400
Content-Disposition: inline
In-Reply-To: <20120626.220155.1298849942906073647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 26, 2012 at 10:01:55PM -0700, David Miller wrote:
> 
> Bad API, embedded gotos, error prone, etc.
> 
> Next pass we'll have to deal with the RTA_PUT*() macros
> too.

I have a patchset that does just that that I was about to submit today.
I'll rebase on top of these patches.

Reviewed-by: Thomas Graf <tgraf@suug.ch>
