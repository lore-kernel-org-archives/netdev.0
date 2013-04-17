From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH V6] Bundle fixes for Xen netfront / netback
Date: Wed, 17 Apr 2013 17:20:40 -0400 (EDT)
Message-ID: <20130417.172040.715712761117441338.davem@davemloft.net>
References: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
	<20130417193119.GA22059@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, wdauchy@gmail.com, ian.campbell@citrix.com
To: konrad.wilk@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966383Ab3DQVUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:20:44 -0400
In-Reply-To: <20130417193119.GA22059@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Date: Wed, 17 Apr 2013 15:31:19 -0400

> On Wed, Apr 17, 2013 at 06:41:59PM +0100, Wei Liu wrote:
>> Final round of this series. All acked and ready to go in.
> 
> Should you put CC: stable@vger.kernel.org on some of them?

These patches are targetted at net-next, so that would not
be appropriate.

If any of this needs to go to -stable, it should have been
targetted at 'net' not 'net-next'.
