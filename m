From: David Miller <davem@davemloft.net>
Subject: Re: 8139cp: Add dma_mapping_error checking
Date: Fri, 09 Aug 2013 11:18:32 -0700 (PDT)
Message-ID: <20130809.111832.658646847887126827.davem@davemloft.net>
References: <20130804005227.CA1B0660D02@gitolite.kernel.org>
	<20130806150114.GA29184@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, romieu@fr.zoreil.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965075Ab3HISSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:18:33 -0400
In-Reply-To: <20130806150114.GA29184@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 6 Aug 2013 11:01:14 -0400

> 8139cp: Fix skb leak in rx_status_loop failure path.
> Introduced in cf3c4c03060b688cbc389ebc5065ebcce5653e96
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, but Dave please take care of all of the usual formalities that
I took care for you here next time.

Reference commits by SHA1 ID _and_ in parenthesis and double quotes, show
the commit message header line as well.

Post patches as self contained patch postings, so that I don't have to
edit the commit message and attend to the other details like that.

Thanks.
