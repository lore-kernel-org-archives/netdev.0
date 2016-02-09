From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] bridge: mdb: flag offloaded mdb entries
Date: Tue, 09 Feb 2016 04:43:39 -0500 (EST)
Message-ID: <20160209.044339.1256711752004759405.davem@davemloft.net>
References: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbcBIJnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 04:43:46 -0500
In-Reply-To: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  3 Feb 2016 09:57:03 +0100

> This patchset extends uapi to let the user know if an mdb entry is
> offloaded.

Series applied, but I really hope that it is safe to use that empry u8
slot for the flag field.

Thanks.
