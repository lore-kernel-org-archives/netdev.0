From: David Miller <davem@davemloft.net>
Subject: Re: wimax: i2400m - prevent a possible kernel bug (commit
 4eee6a3a04)
Date: Thu, 05 Apr 2012 19:16:32 -0400 (EDT)
Message-ID: <20120405.191632.294264420629020807.davem@davemloft.net>
References: <20120405114245.GD1963@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: phil.sutter@viprinet.com, netdev@vger.kernel.org
To: jwboyer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550Ab2DEXQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 19:16:36 -0400
In-Reply-To: <20120405114245.GD1963@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Boyer <jwboyer@redhat.com>
Date: Thu, 5 Apr 2012 07:42:46 -0400

> I noticed you just sent another round of net patches to the stable
> trees, but I didn't see commit 4eee6a3a04 included.  You might want to
> include that in the next round, as we've seen it on a 3.3 kernel in
> Fedora (rhbz 808603).

Queued up for -stable, thanks.
