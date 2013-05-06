From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: remove dead code
Date: Mon, 06 May 2013 12:17:22 -0400 (EDT)
Message-ID: <20130506.121722.2064597841318034990.davem@davemloft.net>
References: <1367854820-4129-1-git-send-email-wei.liu2@citrix.com>
	<20130506161033.GD32539@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Ian.Campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613Ab3EFQRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 12:17:24 -0400
In-Reply-To: <20130506161033.GD32539@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 6 May 2013 17:10:33 +0100

> On Mon, May 06, 2013 at 04:40:20PM +0100, Wei Liu wrote:
>> The array mmap_pages is never touched in the initialization function. This is
>> remnant of mapping mechanism, which does exist upstream.
>> 
> 
> This patch targets net-next.

http://marc.info/?l=linux-netdev&m=136730964130303&w=2
