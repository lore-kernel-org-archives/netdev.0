From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH 0/8] dcbnl: Major simplifications
Date: Thu, 14 Jun 2012 03:54:35 -0400
Message-ID: <20120614075435.GA29185@canuck.infradead.org>
References: <cover.1339591572.git.tgraf@suug.ch>
 <20120613.155541.26513304496438357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:41317 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073Ab2FNHyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 03:54:38 -0400
Content-Disposition: inline
In-Reply-To: <20120613.155541.26513304496438357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 03:55:41PM -0700, David Miller wrote:
> Lots of deleted code, I like it :-)
> 
> Applied, but could you send a follow-on patch to use BUG_ON() instead
> of that "if (!ptr) { /* ... */ BUG(); }" construct?

Sure, I must have had a weak moment right there :)
