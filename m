From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netrom: copy_datagram_iovec can fail
Date: Tue, 04 Sep 2012 12:58:34 -0400 (EDT)
Message-ID: <20120904.125834.119491341212595546.davem@davemloft.net>
References: <20120904141315.26374.38822.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443Ab2IDQ6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 12:58:38 -0400
In-Reply-To: <20120904141315.26374.38822.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 04 Sep 2012 15:13:18 +0100

> From: Alan Cox <alan@linux.intel.com>
> 
> Check for an error from this and if so bail properly.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied and queued up for -stable, thanks Alan.
