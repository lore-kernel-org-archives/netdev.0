From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Tue, 27 Aug 2013 22:11:58 -0400 (EDT)
Message-ID: <20130827.221158.172647721431017580.davem@davemloft.net>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3H1CL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 22:11:59 -0400
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 27 Aug 2013 13:20:37 -0700

> A number of significant new features and optimizations for net-next/3.12.
> Highlights are:
>  * "Megaflows", an optimization that allows userspace to specify which
>    flow fields were used to compute the results of the flow lookup.
>    This allows for a major reduction in flow setups (the major
>    performance bottleneck in Open vSwitch) without reducing flexibility.
>  * Converting netlink dump operations to use RCU, allowing for
>    additional parallelism in userspace.
>  * Matching and modifying SCTP protocol fields.

Pulled, thanks Jesse.
