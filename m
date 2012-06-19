From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 21:10:33 -0700 (PDT)
Message-ID: <20120618.211033.127841245029278364.davem@davemloft.net>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
	<a22edf13-1bf5-49fb-8ebe-05054f68c129@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab2FSEKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:10:34 -0400
In-Reply-To: <a22edf13-1bf5-49fb-8ebe-05054f68c129@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Mon, 18 Jun 2012 21:03:26 -0700 (PDT)

> David, I understand it, Eric understands it, and maybe one or
> two others. But on the principal of what is "good for the goose
> is good for the gander", you really need to provide a reasonable
> change log entry. Just because you are the network maintainer
> doesn't mean you get to skip all the documented rules about submitting
> patches.

This wasn't going to be the final commit log entry.
