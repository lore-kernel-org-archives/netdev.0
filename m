From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] mlxsw: small driver update
Date: Fri, 08 Apr 2016 13:07:37 -0400 (EDT)
Message-ID: <20160408.130737.1379821883201014485.davem@davemloft.net>
References: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
	<20160408155155.GC1932@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbcDHRHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 13:07:45 -0400
In-Reply-To: <20160408155155.GC1932@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 8 Apr 2016 17:51:55 +0200

> Fri, Apr 08, 2016 at 05:45:20PM CEST, jiri@resnulli.us wrote:
>>From: Jiri Pirko <jiri@mellanox.com>
>>
>>Cosmetics, in preparation to sharedbuffer patchset.
> 
> Dave, I just realized there is dependency on:
> "devlink: remove implicit type set in port register" which I sent couple
> of minutes after this patchset. I can either resend in bulk, or if you
> could apply in order, that would be great.

The devlink series also lacked a header posting.  Can you just sort this
all out properly and respin everything?

Thanks.

> Thanks and sorry, owe you another beer :)

:-)
