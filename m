From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: Implement ethtool flash_device entry point.
Date: Wed, 01 Feb 2012 23:13:25 -0500 (EST)
Message-ID: <20120201.231325.1269836056843927966.davem@davemloft.net>
References: <1328144561-25067-1-git-send-email-kgudipat@brocade.com>
	<1328146194.2541.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kgudipat@brocade.com, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165Ab2BBEOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 23:14:31 -0500
In-Reply-To: <1328146194.2541.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 2 Feb 2012 01:29:54 +0000

> On Wed, 2012-02-01 at 17:02 -0800, kgudipat@brocade.com wrote:
>> From: Krishna Gudipati <kgudipat@brocade.com>
>> 
>> Incorporated review comments from Ben Hutchings.
>> 
>> Change details:
>> 	- Implement ethtool flash_device() entry point to write the
>> 	  firmware image to the flash firmware partition.
>> 
>> Signed-off-by: Krishna Gudipati <kgudipat@brocade.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
