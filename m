From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Tue, 23 Apr 2013 03:05:48 -0400 (EDT)
Message-ID: <20130423.030548.1875714803946607140.davem@davemloft.net>
References: <20130422.160834.1941810644323096368.davem@davemloft.net>
	<1366687841.21136.6.camel@cr0>
	<1366698455.21136.11.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586Ab3DWHFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 03:05:53 -0400
In-Reply-To: <1366698455.21136.11.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 23 Apr 2013 14:27:35 +0800

> Or maybe I should raise the question again: should we forbid
> compiling IPv6 as a module from now on? At least some popular
> distributions already use CONFIG_IPV6=y. The only IPv6 things we
> really need to compile as a module is probably just procfs/sysfs
> stuffs.

We're not removing IPV6 modularity.

Please surprise me and fix this properly.

Thanks.
