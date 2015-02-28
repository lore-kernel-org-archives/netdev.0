From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: Verify permission to link_net in newlink
Date: Sat, 28 Feb 2015 15:15:24 -0500 (EST)
Message-ID: <20150228.151524.2190854506868858318.davem@davemloft.net>
References: <54EF3338.8000409@6wind.com>
	<87egpcmi3v.fsf_-_@x220.int.ebiederm.org>
	<877fv4mi20.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugene.yakubovich@coreos.com, netdev@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbB1UPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 15:15:25 -0500
In-Reply-To: <877fv4mi20.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 26 Feb 2015 16:20:07 -0600

> When applicable verify that the caller has permisson to the underlying
> network namespace for a newly created network device.
> 
> Similary checks exist for the network namespace a network device will
> be created in.
> 
> Fixes: v4.0-rc1
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
