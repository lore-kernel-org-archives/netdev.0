From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 3/5] pktgen: display IPv4 address in human-readable
 format
Date: Wed, 10 Oct 2012 22:34:08 -0400 (EDT)
Message-ID: <20121010.223408.1057044629948235751.davem@davemloft.net>
References: <1349840900-24138-1-git-send-email-amwang@redhat.com>
	<1349840900-24138-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159Ab2JKCeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:34:12 -0400
In-Reply-To: <1349840900-24138-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 10 Oct 2012 11:48:18 +0800

> It is weird to display IPv4 address in %x format, what's more,
> IPv6 address is disaplayed in human-readable format too. So,
> make it human-readable.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
